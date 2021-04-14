import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Partner with ChangeNotifier {
  var qID;
  var userID;

  var chatID;

  void setQuestionID(var qID) {
    this.qID = qID;
  }

  void setUserID(var userID) {
    this.userID = userID;
  }

  void resetProvider() {
    this.chatID = null;
    this.qID = null;
    this.userID = null;
  }

  Future<void> joinWaitingRoom(double answer, double lookingFor) async {
    await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(userID)
        .setData({
      "answer": answer,
      "looking_for": lookingFor,
    });
  }

  Future<void> createChat(String partnerID) async {
    // delete waiting room entry
    await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(userID)
        .delete();

    // create a chat document
    DocumentReference chatDoc = await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('chats')
        .add({'user1_id': userID, 'user2_id': partnerID});

    // notify partner i found him
    await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(partnerID)
        .updateData({'chat': chatDoc.documentID});

    notifyChatFound(chatDoc.documentID);
  }

  Future<void> searchForPartner(double answer, double lookingFor) async {
    // look once to see if there is someone who matches conditions
    QuerySnapshot waitersSnapshot = await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .getDocuments();

    for (var i in waitersSnapshot.documents) {
      // if match, create chat
      if (i.documentID != userID &&
          i['answer'] == lookingFor &&
          i['looking_for'] == answer) {
        await createChat(i.documentID);
        return;
      }
    }
    // if no match found, tell user to come back later
    notifyChatNotFound();

    // if no match found, setup stream listner that waits for flag
    StreamSubscription foundListener;
    Stream<DocumentSnapshot> waitingSnapshot = Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(userID)
        .snapshots();

    foundListener = waitingSnapshot.listen((document) async {
      // when flaged, delete my waiting_room + stop stream
      String flag = document.data['chat'];
      print(flag);
      if (document.data != null && document.data['chat'] != null) {
        print("Chat Found At:");
        print(document.data['chat']);

        // notify that chat was found
        notifyChatFound(document.data['chat']);
        // stop stream
        foundListener.cancel();

        // delete personal waiting room entry
        await Firestore.instance
            .collection('questions')
            .document(qID)
            .collection('waiting_room')
            .document(userID)
            .delete();
      }
    });
  }

  Future<void> notifyChatFound(String newChatID) async {
    this.chatID = newChatID;
    notifyListeners();
    // add chat id to active_chats for user

    await Firestore.instance
        .collection('users')
        .document(userID)
        .collection("active_questions")
        .document(qID)
        .updateData(
      {
        "active_chats": FieldValue.arrayUnion([chatID])
      },
    );
  }

  void notifyChatNotFound() {
    this.chatID = 0;
    notifyListeners();
  }
}
