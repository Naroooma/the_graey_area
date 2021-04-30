// listview of all active questions, with small preview of new chats
// navigation to new questions

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/models/category.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/auth.dart';
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

  Color correspondingColor(List<dynamic> _allCategories, String categoryName) {
    var color;
    var matched = _allCategories.where((item) => item.name == categoryName);
    matched.forEach((item) {
      color = HexColor(item.color);
    });
    return color;
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    void rebuild(dynamic a) {
      if (a == 'from back') {
        setState(() {});
      }
    }

    var _screenSize = MediaQuery.of(context).size;

    FirebaseUser user = Provider.of<Auth>(context).user;

    List<dynamic> allQuestions = Provider.of<List<Question>>(context);
    List<dynamic> allCategories = Provider.of<List<Category>>(context);

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
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // partneredQuestions are the ones that have chats
                List<ActiveQuestion> partneredQuestions = snapshot.data
                    .where((doc) => doc.activeChats != null)
                    .toList();

                // unpartneredQuesion if in active_question => waiting room
                // List<ActiveQuestion> unpartneredQuestions = snapshot.data
                //     .where((doc) => doc.activeChats == null)
                //     .toList();
                // open stream for all unpartneredquestions
                // for (var unpartneredQ in unpartneredQuestions) {
                //   print(unpartneredQ);
                //   Provider.of<Partner>(context, listen: false)
                //       .openPartnerStream(user.uid, unpartneredQ.id);
                // }
                return FutureBuilder(
                    future: DatabaseService()
                        .unPartneredList(snapshot.data, user.uid),
                    builder: (context, unPartneredSnapshot) {
                      if (unPartneredSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      List unPartneredIDList = unPartneredSnapshot.data;

                      for (var unpartneredQID in unPartneredIDList) {
                        Provider.of<Partner>(context, listen: false)
                            .openPartnerStream(user.uid, unpartneredQID);
                      }

                      return ListView.builder(
                        itemCount: partneredQuestions.length,
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
                                          question.id ==
                                          partneredQuestions[i].id)
                                      .toList()[0]
                                      .text,
                                  // get all questions
                                  // display matching text for docID

                                  style: TextStyle(
                                      fontFamily: 'PT_Serif', fontSize: 20),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, ActiveChatsScreen.routeName,
                                          arguments: partneredQuestions[i])
                                      .then((value) => rebuild(value));
                                },
                              ),
                              trailing: FutureBuilder(
                                future: DatabaseService().doesQNewPartner(
                                    partneredQuestions[i].id,
                                    user.uid,
                                    partneredQuestions[i].activeChats),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.waiting) {
                                    if (snapshot.data == true) {
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
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              child: Wrap(
                                  spacing: 10,
                                  children: List<Widget>.generate(
                                    allQuestions
                                        .where((question) =>
                                            question.id ==
                                            partneredQuestions[i].id)
                                        .toList()[0]
                                        .questionCategories
                                        .length,
                                    (int index) {
                                      return Icon(
                                        Icons.circle,
                                        color: correspondingColor(
                                                allCategories,
                                                allQuestions
                                                    .where((question) =>
                                                        question.id ==
                                                        partneredQuestions[i]
                                                            .id)
                                                    .toList()[0]
                                                    .questionCategories[index])
                                            .withOpacity(0.8),
                                      );
                                    },
                                  )),
                            ),
                          ],
                        ),
                      );
                    });
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
