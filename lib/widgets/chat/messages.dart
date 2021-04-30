import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/database.dart';
import 'package:the_graey_area/models/message.dart';
import 'package:the_graey_area/providers/auth.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final qID;
  final chatID;

  Messages(this.qID, this.chatID);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context).user;

    return StreamBuilder(
        stream: DatabaseService().messagesinChat(qID, chatID, user.uid),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Message> messagesList = chatSnapshot.data;
          DatabaseService().readMessage(qID, chatID, user.uid);
          DatabaseService().seenPartner(qID, chatID, user.uid);
          return ListView.builder(
            reverse: true,
            itemCount: messagesList.length,
            itemBuilder: (ctx, index) => MessageBubble(
              messagesList[index],
            ),
          );
        });
  }
}
