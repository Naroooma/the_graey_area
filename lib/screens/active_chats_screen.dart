// button to find new partner for the question
// list / grid / scroll of all users

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/auth.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/screens/question_screen.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';
import '../database.dart';

class ActiveChatsScreen extends StatefulWidget {
  static const routeName = '/active-chats-screen';

  @override
  _ActiveChatsScreenState createState() => _ActiveChatsScreenState();
}

class _ActiveChatsScreenState extends State<ActiveChatsScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void rebuild(dynamic a) {
    print(a);
    if (a == 'from back') {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('REBUILT');
    // var _screenSize = MediaQuery.of(context).size;
    //
    final user = Provider.of<Auth>(context).user;

    var question = ModalRoute.of(context).settings.arguments as ActiveQuestion;
    var questionID = question.id;

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
          onTap: () => Navigator.of(context).pop('from back'),
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
            onPressed: () => Navigator.of(context)
                .pushNamed(QuestionScreen.routeName,
                    arguments: Question(
                        id: questionID,
                        text: allQuestions
                            .where((q) => questionID == q.id)
                            .toList()[0]
                            .text))
                .then((value) => rebuild(value)),
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
            child: StreamBuilder<List<dynamic>>(
                stream: DatabaseService().activeChatsforQ(questionID, user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  List activeChats = snapshot.data;
                  print(snapshot.data);
                  return ListView.builder(
                    itemCount: activeChats.length,
                    itemBuilder: (context, i) => Column(
                      children: [
                        Divider(
                          height: 10.0,
                        ),
                        ListTile(
                          title: InkWell(
                            child:
                                // user == null || user.uid == null
                                //     ? CircularProgressIndicator()
                                //     :
                                FutureBuilder<String>(
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
                                              fontFamily: 'PT_Serif',
                                              fontSize: 20),
                                        );
                                      }
                                    }),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ChatScreen.routeName, arguments: [
                                question.id,
                                activeChats[i]
                              ]).then((value) => rebuild(value));
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FutureBuilder(
                                  future: DatabaseService().partnerSeen(
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
                              StreamBuilder<Object>(
                                  stream: DatabaseService().messageCount(
                                      question.id, activeChats[i]),
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
                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      "${snapshot.data}",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
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
                  );
                }),
          ),
        ],
      ),
    );
  }
}
