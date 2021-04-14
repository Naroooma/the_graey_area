// listview of all active questions, with small preview of new chats
// navigation to new questions

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_graey_area/screens/active_chats_screen.dart';
import 'package:the_graey_area/screens/questions_list_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';

class QuestionsChatsScreen extends StatefulWidget {
  static const routeName = '/questions-chats-screen';

  @override
  _QuestionsChatsScreenState createState() => _QuestionsChatsScreenState();
}

class _QuestionsChatsScreenState extends State<QuestionsChatsScreen> {
  final dummyData = [
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 2},
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 0}
  ];

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: _searchActive
      //     ? buildSearchBar()
      //    :
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Chats",
          style: TextStyle(
              color: Theme.of(context).primaryColor, fontFamily: 'PT_Serif'),
        ),
        backgroundColor: Colors.grey[300],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        actions: [
          SizedBox(
            width: _screenSize.width / 20,
          ),
          GestureDetector(
            onTap: () {
              // setState(() {
              //   _searchActive = !_searchActive;
              //   print(_searchActive);
              // });
              // showSearch(
              //     context: context,
              //     delegate:
              //         Search(_allQuestions, _matchQuestions, allCategories));
            },
            child: Icon(Icons.search, size: 30),
          ),
          SizedBox(
            width: _screenSize.width / 20,
          ),
          GestureDetector(
            child: Icon(Icons.menu, size: 30), // change this size and style
            onTap: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
          SizedBox(
            width: _screenSize.width / 20,
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
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(userSnap.data.uid)
                .collection('active_questions')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              print(snapshot.data.documents);
              List activeQuestions = snapshot.data.documents;
              print(activeQuestions);
              return ListView.builder(
                itemCount: activeQuestions.length,
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
                          activeQuestions[i].documentID,
                          style: TextStyle(fontFamily: 'PT_Serif'),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, ActiveChatsScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
        onPressed: () => Navigator.pushReplacementNamed(
            context, QuestionsListScreen.routeName),
      ),
    );
  }
}
