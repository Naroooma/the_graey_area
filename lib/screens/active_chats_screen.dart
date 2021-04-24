// button to find new partner for the question
// list / grid / scroll of all users

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/screens/question_screen.dart';
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

    var allQuestions = Provider.of<List<Question>>(context);

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
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
                QuestionScreen.routeName,
                arguments: Question(
                    id: question.id,
                    text: allQuestions
                        .where((q) => question.id == q.id)
                        .toList()[0]
                        .text)),
            child: Text('Find New Partner'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).primaryColor.withOpacity(0.7);
                return Theme.of(context).primaryColor;
              }),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 500,
            child: ListView.builder(
              itemCount: activeChats.length,
              itemBuilder: (context, i) => Column(
                children: [
                  Divider(
                    height: 10.0,
                  ),
                  ListTile(
                    title: InkWell(
                      child: FutureBuilder<String>(
                          future: DatabaseService().partnerUsername(
                              activeChats[i], question.id, user.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else {
                              return Text(
                                // get all questions
                                // display matching text for docID
                                snapshot.data == null
                                    ? 'Deleted User'
                                    : snapshot.data,
                                style: TextStyle(
                                    fontFamily: 'PT_Serif', fontSize: 20),
                              );
                            }
                          }),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(
                            ChatScreen.routeName,
                            arguments: [question.id, activeChats[i]]);
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder(
                            future: DatabaseService().isNewPartner(
                                question.id, activeChats[i], user.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.waiting) {
                                if (snapshot.data == false) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    child: Icon(
                                      Icons.star,
                                    ),
                                  );
                                }
                                return SizedBox();
                              }
                              return SizedBox();
                            }),
                        SizedBox(
                          width: 5,
                        ),
                        StreamBuilder<Object>(
                            stream: DatabaseService()
                                .messageCount(question.id, activeChats[i]),
                            builder: (context, messageCountSnapshot) {
                              if (messageCountSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              }
                              return FutureBuilder(
                                  future: DatabaseService()
                                      .unreadMessageCounter(
                                          question.id,
                                          activeChats[i],
                                          user.uid,
                                          messageCountSnapshot.data),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.waiting) {
                                      if (snapshot.data == 0) {
                                        return SizedBox();
                                      } else {
                                        return CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            "${snapshot.data}",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }
                                    }
                                    return SizedBox();
                                  });
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
