import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_graey_area/widgets/partner_searcher.dart';

import '../widgets/app_drawer.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'chat_screen.dart';

class QuestionScreen extends StatefulWidget {
  static const routeName = '/question-screen';

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  var _slidervalue = 50.0;

  var userOpinion = 3.0;
  var partnerOpinion = 3.0;

  bool answered = false;

  bool searching = false;

  var text = "Your Opinion";

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final question =
        ModalRoute.of(context).settings.arguments as DocumentSnapshot;
    final questionId = question.documentID;
    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_screenSize.width / 15),
          child: Column(
            children: [
              Container(
                height: _screenSize.height / 3,
                child: AutoSizeText(
                  question.data['text'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontFamily:
                        Theme.of(context).textTheme.headline1.fontFamily,
                    fontStyle: FontStyle.italic,
                    fontSize: _screenSize
                        .width, // maximum so that autosize makes is smaller
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              searching
                  ? PartnerSearcher(questionId, userOpinion, partnerOpinion)
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final inAnimation = Tween<Offset>(
                                begin: Offset(1.5, 0.0), end: Offset(0.0, 0.0))
                            .animate(animation);
                        final outAnimation = Tween<Offset>(
                                begin: Offset(-1.5, 0.0), end: Offset(0.0, 0.0))
                            .animate(animation);
                        if (child.key == ValueKey<String>("Your Opinion")) {
                          return ClipRect(
                            child: SlideTransition(
                              position: outAnimation,
                              child: child,
                            ),
                          );
                        } else {
                          return ClipRect(
                            child: SlideTransition(
                              position: inAnimation,
                              child: child,
                            ),
                          );
                        }
                      },
                      child: Container(
                        key: ValueKey<String>(text),
                        child: Column(
                          children: [
                            Container(
                              height: _screenSize.height / 25,
                              child: AutoSizeText(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontFamily: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .fontFamily,
                                  fontStyle: FontStyle.italic,
                                  fontSize: _screenSize
                                      .width, // maximum so that autosize makes is smaller
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Slider(
                              min: 0,
                              max: 100,
                              value: _slidervalue,
                              divisions: 4,
                              label: (_slidervalue / 25 + 1).toInt().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _slidervalue = value;
                                });
                              },
                              activeColor: Theme.of(context).accentColor,
                              inactiveColor: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.5),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      AutoSizeText(
                                        "No",
                                        style: TextStyle(
                                          fontSize: _screenSize.width,
                                          color: Theme.of(context).accentColor,
                                          fontFamily: Theme.of(context)
                                              .textTheme
                                              .headline1
                                              .fontFamily,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      AutoSizeText(
                                        "Yes",
                                        style: TextStyle(
                                          fontSize: _screenSize.width,
                                          color: Theme.of(context).accentColor,
                                          fontFamily: Theme.of(context)
                                              .textTheme
                                              .headline1
                                              .fontFamily,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed))
                                      return Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.7);
                                    return Theme.of(context).accentColor;
                                  },
                                ),
                              ),
                              onPressed: () async {
                                FirebaseUser user =
                                    await FirebaseAuth.instance.currentUser();

                                if (text == "Your Opinion") {
                                  userOpinion = _slidervalue / 25 + 1;
                                  await Firestore.instance
                                      .collection('users')
                                      .document(user.uid)
                                      .collection("active_questions")
                                      .document(questionId)
                                      .setData({
                                    "answer": userOpinion,
                                  }, merge: true);
                                  _slidervalue = 50;
                                } else {
                                  partnerOpinion = _slidervalue / 25 + 1;
                                  // if answered second question, go to waiting room
                                  Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: [
                                        question.data['text'],
                                        questionId
                                      ]);
                                  await Firestore.instance
                                      .collection('questions')
                                      .document(questionId)
                                      .collection('waiting_room')
                                      .document(user.uid)
                                      .setData({
                                    "answer": userOpinion,
                                    "looking_for": partnerOpinion,
                                  });
                                  await Firestore.instance
                                      .collection('users')
                                      .document(user.uid)
                                      .collection("active_questions")
                                      .document(questionId)
                                      .updateData({
                                    "in_waiting_room": true,
                                  });

                                  _slidervalue = 50;
                                }

                                setState(() {
                                  if (text == "Your Opinion") {
                                    answered = true;
                                    text = "Talk to someone who Answered:";
                                  } else {
                                    searching = true;
                                  }
                                });
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).primaryColor,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
