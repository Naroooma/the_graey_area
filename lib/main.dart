import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/database.dart';
import 'package:the_graey_area/home.dart';
import 'package:the_graey_area/models/category.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/screens/active_chats_screen.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';

import './screens/category_picker_screen.dart';

import './screens/question_screen.dart';

import './providers/categories.dart';
import './providers/auth.dart';
import 'providers/partner.dart';
import 'providers/search.dart';
import 'screens/auth_screen.dart';
import 'screens/questions_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  return runApp(MyApp());
}

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
        Provider<DatabaseService>.value(
          value: DatabaseService(),
        ),
        StreamProvider<List<Category>>.value(
            value: DatabaseService().allCategories),
        StreamProvider<List<Question>>.value(
            value: DatabaseService().allQuestions),
        // StreamProvider<FirebaseUser>.value(
        //   value: FirebaseAuth.instance.onAuthStateChanged,
        // ),
        ChangeNotifierProvider<Categories>(
          create: (_) => Categories(),
        ),
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider<Search>(
          create: (_) => Search(),
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
        home: Home(),
        routes: {
          QuestionsChatsScreen.routeName: (ctx) => QuestionsChatsScreen(),
          QuestionsListScreen.routeName: (ctx) => QuestionsListScreen(),
          ActiveChatsScreen.routeName: (ctx) => ActiveChatsScreen(),
          CategoryPickerScreen.routeName: (ctx) => CategoryPickerScreen(),
          QuestionScreen.routeName: (ctx) => QuestionScreen(),
          ChatScreen.routeName: (ctx) => ChatScreen(),
        },
      ),
    );
  }
}
