import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/category_picker_screen.dart';
import './screens/questions_list_screen.dart';

import './providers/categories.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.grey[800],
          accentColor: Colors.grey[50],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            headline5: TextStyle(
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
              // need to log out because token persists, but provider does not
              //Provider.of<Auth>(ctx).signout();

              final isNewUser = Provider.of<Auth>(ctx).isNewUser;

              if (isNewUser) {
                return CategoryPickerScreen();
              } else {
                return QuestionsListScreen();
              }
            } else {
              return AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
