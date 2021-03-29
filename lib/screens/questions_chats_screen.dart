// listview of all active questions, with small preview of new chats
// navigation to new questions

import 'package:flutter/material.dart';

class QuestionsChatScreen extends StatefulWidget {
  @override
  _QuestionsChatScreenState createState() => _QuestionsChatScreenState();
}

class _QuestionsChatScreenState extends State<QuestionsChatScreen> {
  final dummyData = [
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 2},
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 0}
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyData.length,
      itemBuilder: (context, i) => Column(
        children: [
          Divider(
            height: 10.0,
          ),
          ListTile(
            title: Text(
              dummyData[i]['question'],
              style: TextStyle(fontFamily: 'PT_Serif'),
            ),
          ),
        ],
      ),
    );
  }
}
