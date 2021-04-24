import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/screens/auth_screen.dart';
import 'package:the_graey_area/screens/category_picker_screen.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';

class Home extends StatelessWidget {
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
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    if (user != null) {
      return FutureBuilder(
          future: catChosen(),
          builder: (ctx, futuresnapshot) {
            // need to log out because token persists, but provider does not
            //Provider.of<Auth>(ctx).signout();

            //final isNewUser =
            //    userSnapshot.data.metadata.lastSignInTime ==
            //        userSnapshot.data.metadata.creationTime;
            //final isNewUser = Provider.of<Auth>(ctx).isNewUser;
            if (futuresnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.grey[800],
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              if (futuresnapshot.data == null || futuresnapshot.data == true) {
                return CategoryPickerScreen();
              } else {
                return QuestionsChatsScreen();
              }
            }
          });
    } else {
      return AuthScreen();
    }
  }
}
