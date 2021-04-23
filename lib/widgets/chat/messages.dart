import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/database.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final qID;
  final chatID;

  Messages(this.qID, this.chatID);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return user == null || user.uid == null
        ? CircularProgressIndicator()
        : StreamBuilder(
            stream: Firestore.instance
                .collection('questions')
                .document(qID)
                .collection('chats')
                .document(chatID)
                .collection('messages')
                .orderBy(
                  'createdAt',
                  descending: true,
                )
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              DatabaseService().readMessage(qID, chatID, user.uid);
              final chatDocs = chatSnapshot.data.documents;
              return ListView.builder(
                reverse: true,
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) => MessageBubble(
                  chatDocs[index]['text'],
                  chatDocs[index]['userId'] == user.uid,
                  chatDocs[index]['username'],
                  key: ValueKey(chatDocs[index].documentID),
                ),
              );
            });
  }
}
