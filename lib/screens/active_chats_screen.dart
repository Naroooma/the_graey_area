import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/active_question.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/auth.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/screens/question_screen.dart';
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
    if (a == 'from back') {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    final user = Provider.of<Auth>(context).user;

    var question = ModalRoute.of(context).settings.arguments as ActiveQuestion;
    var questionID = question.id;

    var allQuestions = Provider.of<List<Question>>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Active Chats",
          style: TextStyle(
              color: Theme.of(context).primaryColor, fontFamily: 'PT_Serif'),
        ),
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
            child: Icon(Icons.menu, size: _screenheight * 0.035),
            onTap: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
          SizedBox(
            width: _screenheight * 0.035,
          ),
        ],
      ),
      endDrawer: AppDrawer(context),
      backgroundColor: Theme.of(context).accentColor,
      key: _scaffoldKey,
      body: Column(
        children: [
          SizedBox(height: _screenheight * 0.035),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: _screenwidth * 0.5, height: _screenheight * 0.05),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(QuestionScreen.routeName,
                      arguments: Question(
                          id: questionID,
                          text: allQuestions
                              .where((q) => questionID == q.id)
                              .toList()[0]
                              .text))
                  .then((value) => rebuild(value)),
              child: Text(
                'Find New Partner',
                style: TextStyle(
                    fontSize: _screenheight * 0.02, fontFamily: 'PT_Serif'),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Theme.of(context).primaryColor.withOpacity(0.7);
                  return Theme.of(context).primaryColor;
                }),
              ),
            ),
          ),
          SizedBox(height: _screenheight * 0.035),
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: DatabaseService().activeChatsforQ(questionID, user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  );
                }
                List activeChats = snapshot.data;
                return ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: activeChats.length,
                  itemBuilder: (context, i) => Column(
                    children: [
                      Divider(
                        height: _screenheight * 0.01,
                      ),
                      FutureBuilder(
                        future: DatabaseService().partnerUsername(
                            activeChats[i], question.id, user.uid),
                        builder: (context, partsnapshot) {
                          if (partsnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(_screenheight * 0.012),
                                child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).primaryColor)));
                          } else {
                            return ListTile(
                              title: InkWell(
                                child: Text(
                                  // display matching username
                                  partsnapshot.data == null
                                      ? 'Deleted User'
                                      : partsnapshot.data,
                                  style: TextStyle(
                                      fontFamily: 'PT_Serif',
                                      fontSize: _screenheight * 0.025),
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: [
                                        question.id,
                                        activeChats[i],
                                      ]).then((value) => rebuild(value));
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FutureBuilder(
                                      future: DatabaseService().partnerSeen(
                                          question.id,
                                          activeChats[i],
                                          user.uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState !=
                                            ConnectionState.waiting) {
                                          if (snapshot.data == false) {
                                            return CircleAvatar(
                                              radius: _screenheight * 0.025,
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
                                      if (messageCountSnapshot.data == null) {
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
                                                    width: _screenwidth * 0.025,
                                                  ),
                                                  CircleAvatar(
                                                    radius:
                                                        _screenheight * 0.025,
                                                    backgroundColor: Colors.red,
                                                    child: Text(
                                                      "${snapshot.data}",
                                                      style: TextStyle(
                                                          fontSize:
                                                              _screenheight *
                                                                  0.025,
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
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
