// listview of all active questions, with small preview of new chats
// navigation to new questions

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/partner.dart';
import 'package:the_graey_area/screens/active_chats_screen.dart';
import 'package:the_graey_area/screens/questions_list_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';
import '../database.dart';

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

    FirebaseUser user = Provider.of<FirebaseUser>(context);

    List<dynamic> allQuestions = Provider.of<List<Question>>(context);

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
      // if user has logged out, close stream
      body: user == null || user.uid == null
          ? CircularProgressIndicator()
          : StreamBuilder<List<ActiveQuestion>>(
              stream: Provider.of<DatabaseService>(context)
                  .activeQuestions(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                for (var i in snapshot.data) {
                  print(i.id);
                }
                List<ActiveQuestion> activeQuestions = snapshot.data
                    .where((doc) => doc.activeChats != null)
                    .toList();

                List<ActiveQuestion> unpartneredQuestions = snapshot.data
                    .where((doc) => doc.activeChats == null)
                    .toList();
                // open stream for all unpartneredquestions
                Provider.of<Partner>(context, listen: false)
                    .setUserID(user.uid);
                for (var unpartneredQ in unpartneredQuestions) {
                  Provider.of<Partner>(context, listen: false).qID =
                      unpartneredQ.id;
                  Provider.of<Partner>(context, listen: false)
                      .openPartnerStream();
                }
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
                            // text of question that matches id
                            allQuestions
                                .where((question) =>
                                    question.id == activeQuestions[i].id)
                                .toList()[0]
                                .text,
                            // get all questions
                            // display matching text for docID

                            style: TextStyle(fontFamily: 'PT_Serif'),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                                context, ActiveChatsScreen.routeName,
                                arguments: activeQuestions[i]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
        onPressed: () =>
            Navigator.pushNamed(context, QuestionsListScreen.routeName),
      ),
    );
  }
}
