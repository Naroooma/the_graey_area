// button to find new partner for the question
// list / grid / scroll of all users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';
import '../database.dart';

class ActiveChatsScreen extends StatelessWidget {
  static const routeName = '/active-chats-screen';

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // var _screenSize = MediaQuery.of(context).size;
    //
    final user = Provider.of<FirebaseUser>(context);

    var question = ModalRoute.of(context).settings.arguments as ActiveQuestion;
    var activeChats = question.activeChats;

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
      body: ListView.builder(
        itemCount: activeChats.length,
        itemBuilder: (context, i) => Column(
          children: [
            Divider(
              height: 10.0,
            ),
            ListTile(
              title: InkWell(
                child: FutureBuilder<String>(
                    future: DatabaseService()
                        .partnerUsername(activeChats[i], question.id, user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        print(snapshot.data);
                        return Text(
                          // get all questions
                          // display matching text for docID
                          snapshot.data == null
                              ? 'Deleted User'
                              : snapshot.data,
                          style: TextStyle(fontFamily: 'PT_Serif'),
                        );
                      }
                    }),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                      ChatScreen.routeName,
                      arguments: [question.id, activeChats[i]]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
