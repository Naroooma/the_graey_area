import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/partner.dart';
import 'package:the_graey_area/widgets/partner_searcher.dart';
import 'package:the_graey_area/widgets/reqAutoText.dart';

import '../widgets/app_drawer.dart';
import '../database.dart';

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

  Widget answerTile(_screenSize, questionId, context) {
    return Container(
      key: ValueKey<String>(text),
      child: Column(
        children: [
          ReqAutoText(text, _screenSize, _screenSize.height / 25),
          SizedBox(
            height: (_screenSize.height - MediaQuery.of(context).padding.top) *
                0.03,
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
            width: _screenSize.width * 0.75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReqAutoText(
                    "No",
                    _screenSize,
                    (_screenSize.height - MediaQuery.of(context).padding.top) *
                        0.06),
                ReqAutoText(
                    "Yes",
                    _screenSize,
                    (_screenSize.height - MediaQuery.of(context).padding.top) *
                        0.06),
              ],
            ),
          ),
          SizedBox(
              height:
                  (_screenSize.height - MediaQuery.of(context).padding.top) *
                      0.03),
          ElevatedButton(
            child: Container(
              height:
                  (_screenSize.height - MediaQuery.of(context).padding.top) *
                      0.08,
              width: _screenSize.width * 0.15,
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).primaryColor,
                size: _screenSize.width * 0.1,
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

                // save user answer in firebase
                await DatabaseService()
                    .sendQuestionAnswer(questionId, user.uid, userOpinion);
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
    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    final question = ModalRoute.of(context).settings.arguments as Question;
    final questionId = question.id;
    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            size: _screenheight * 0.035,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => Navigator.of(context).pop('from back'),
        ),
        actions: [
          GestureDetector(
            child: Icon(Icons.menu,
                size: _screenheight * 0.035), // change this size and style
            onTap: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
          SizedBox(
            width: _screenheight * 0.025,
          ),
        ],
      ),
      endDrawer: AppDrawer(context),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_screenwidth * 0.08),
          child: Column(
            children: [
              ReqAutoText(question.text, _screenSize, _screenheight * 0.35),
              SizedBox(
                height: _screenheight * 0.05,
              ),
              searching
                  ? PartnerSearcher(questionId, userOpinion, partnerOpinion)
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: slideAnimation,
                      child: answerTile(_screenSize, questionId, context)),
            ],
          ),
        ),
      ),
    );
  }
}
