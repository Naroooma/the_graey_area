import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';
import 'package:the_graey_area/widgets/chat/new_message.dart';
import 'package:the_graey_area/widgets/reqAutoText.dart';

import '../widgets/chat/messages.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as List;
    final qID = arguments[0];
    final chatID = arguments[1];

    var _screenSize = MediaQuery.of(context).size;
    var allQuestions = Provider.of<List<Question>>(context);
    Question question =
        allQuestions.where((element) => element.id == qID).toList()[0];

    return Scaffold(
      key: _scaffoldKey,
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
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: ReqAutoText(
                  question.text, _screenSize, _screenSize.height / 7),
              padding: EdgeInsets.all(20),
            ),
            Expanded(
              child: Messages(qID, chatID),
            ),
            NewMessage(qID, chatID),
          ],
        ),
      ),
    );
  }
}
