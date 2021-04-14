import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/partner.dart';
import 'package:the_graey_area/widgets/partner_searcher.dart';
import 'package:the_graey_area/widgets/reqAutoText.dart';

import '../widgets/app_drawer.dart';

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

  Widget slideAnimation(Widget child, Animation<double> animation) {
    final inAnimation =
        Tween<Offset>(begin: Offset(1.5, 0.0), end: Offset(0.0, 0.0))
            .animate(animation);
    final outAnimation =
        Tween<Offset>(begin: Offset(-1.5, 0.0), end: Offset(0.0, 0.0))
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
  }

  Widget answerTile(_screenSize, questionId) {
    return Container(
      key: ValueKey<String>(text),
      child: Column(
        children: [
          ReqAutoText(text, _screenSize, _screenSize.height / 25),
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
            inactiveColor: Theme.of(context).accentColor.withOpacity(0.5),
          ),
          Container(
            width: 320,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReqAutoText("No", _screenSize, 50),
                ReqAutoText("Yes", _screenSize, 50)
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            child: Container(
              height: 70,
              width: 70,
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).accentColor.withOpacity(0.7);
                return Theme.of(context).accentColor;
              }),
            ),
            onPressed: () async {
              FirebaseUser user = await FirebaseAuth.instance.currentUser();

              // if answered first question
              if (text == "Your Opinion") {
                userOpinion = _slidervalue / 25 + 1;

                // save user answer in firebase
                await Firestore.instance
                    .collection('users')
                    .document(user.uid)
                    .collection("active_questions")
                    .document(questionId)
                    .setData({"answer": userOpinion}, merge: true);
                // if answered second question
              } else {
                partnerOpinion = _slidervalue / 25 + 1;

                // save userID and questionID to provider
                Provider.of<Partner>(context, listen: false)
                    .setUserID(user.uid);
                Provider.of<Partner>(context, listen: false)
                    .setQuestionID(questionId);

                Provider.of<Partner>(context, listen: false)
                    .joinWaitingRoom(userOpinion, partnerOpinion);
              }

              _slidervalue = 50;

              setState(() {
                if (text == "Your Opinion") {
                  // switch to second questions
                  answered = true;
                  text = "Talk to someone who Answered:";
                } else {
                  // start search for partner
                  searching = true;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question =
        ModalRoute.of(context).settings.arguments as DocumentSnapshot;
    final questionId = question.documentID;
    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              ReqAutoText(
                  question.data['text'], _screenSize, _screenSize.height / 3),
              SizedBox(
                height: 40,
              ),
              searching
                  ? PartnerSearcher(questionId, userOpinion, partnerOpinion)
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: slideAnimation,
                      child: answerTile(_screenSize, questionId)),
            ],
          ),
        ),
      ),
    );
  }
}
