import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';
import 'package:the_graey_area/widgets/chat/new_message.dart';

import '../widgets/chat/messages.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   final fbm = FirebaseMessaging();
  //   fbm.requestNotificationPermissions();
  //   fbm.configure(onMessage: (msg) {
  //     print(msg);
  //     return;
  //   }, onLaunch: (msg) {
  //     print(msg);
  //     return;
  //   }, onResume: (msg) {
  //     print(msg);
  //     return;
  //   });
  //   fbm.subscribeToTopic('chat');
  // }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as List;
    final qID = arguments[0];
    final chatID = arguments[1];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Insert Question Text from database using ID"),
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
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Column(
          children: <Widget>[
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
