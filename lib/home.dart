import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/auth.dart';
import 'package:the_graey_area/screens/auth_screen.dart';
import 'package:the_graey_area/screens/category_picker_screen.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<bool> catChosen() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try {
      DocumentSnapshot favCategories =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (favCategories['fav_categories'] == null) {
        return true;
      } else {
        return false;
      }
    } catch (exception) {
      print("ERROR");
      print(exception);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseUser user = Provider.of<FirebaseUser>(context);
    // print('USER VALUE');
    // print(user);
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, snapshot) {
          var user = snapshot.data;
          Provider.of<Auth>(context).setUser(user);
          if (user != null) {
            return FutureBuilder(
              future: catChosen(),
              builder: (ctx, futuresnapshot) {
                if (futuresnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: Colors.grey[800],
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  if (futuresnapshot.data == null ||
                      futuresnapshot.data == true) {
                    return CategoryPickerScreen();
                  } else {
                    return QuestionsChatsScreen();
                  }
                }
              },
            );
          } else {
            return AuthScreen();
          }
        });
  }
}
