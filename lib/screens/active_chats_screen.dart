// button to find new partner for the question
// list / grid / scroll of all users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';

class ActiveChatsScreen extends StatelessWidget {
  static const routeName = '/active-chats-screen';

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // var _screenSize = MediaQuery.of(context).size;

    var question =
        ModalRoute.of(context).settings.arguments as DocumentSnapshot;
    var activeChats = question.data['active_chats'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: [
          GestureDetector(
            child: Icon(Icons.menu, size: 30), // change this size and style
            onTap: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      endDrawer: AppDrawer(context),
      backgroundColor: Theme.of(context).accentColor,
      key: _scaffoldKey,
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: activeChats.length,
            itemBuilder: (context, i) => Column(
              children: [
                Divider(
                  height: 10.0,
                ),
                ListTile(
                  title: InkWell(
                    child: Text(
                      // get all questions
                      // display matching text for docID
                      activeChats[i],
                      style: TextStyle(fontFamily: 'PT_Serif'),
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                          ChatScreen.routeName,
                          arguments: [question.documentID, activeChats[i]]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
