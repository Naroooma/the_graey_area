import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_graey_area/home.dart';
import 'package:the_graey_area/screens/chat_screen.dart';

import './screens/auth_screen.dart';
import './screens/category_picker_screen.dart';

import './screens/question_screen.dart';

import './providers/categories.dart';
import './providers/auth.dart';
import 'providers/partner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Categories>(
          create: (_) => Categories(),
        ),
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider<Partner>(
          create: (_) => Partner(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.grey[800],
          accentColor: Colors.grey[50],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            headline1: TextStyle(
              fontFamily: 'PT_Serif',
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[800],
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth
              .instance.onAuthStateChanged, // when the auth has changed
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData && (!userSnapshot.data.isAnonymous)) {
              return FutureBuilder(
                  future: catChosen(),
                  builder: (ctx, futuresnapshot) {
                    // need to log out because token persists, but provider does not
                    //Provider.of<Auth>(ctx).signout();

                    //final isNewUser =
                    //    userSnapshot.data.metadata.lastSignInTime ==
                    //        userSnapshot.data.metadata.creationTime;
                    //final isNewUser = Provider.of<Auth>(ctx).isNewUser;
                    if (futuresnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Scaffold(
                        backgroundColor: Colors.grey[800],
                        body: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      print(futuresnapshot.data);
                      if (futuresnapshot.data == null ||
                          futuresnapshot.data == true) {
                        return CategoryPickerScreen();
                      } else {
                        return Home();
                      }
                    }
                  });
            } else {
              return AuthScreen();
            }
          },
        ),
        routes: {
          CategoryPickerScreen.routeName: (ctx) => CategoryPickerScreen(),
          QuestionScreen.routeName: (ctx) => QuestionScreen(),
          ChatScreen.routeName: (ctx) => ChatScreen(),
        },
      ),
    );
  }
}
