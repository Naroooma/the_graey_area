import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_graey_area/models/category.dart';

import 'models/active_question.dart';
import 'models/message.dart';
import 'models/question.dart';

class DatabaseService {
  // references
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference questionsCollection =
      Firestore.instance.collection('questions');
  final CollectionReference categoriesCollection =
      Firestore.instance.collection('categories');
  final CollectionReference userNamesCollection =
      Firestore.instance.collection('userNames');

  // streams all categories in database
  Stream<List<Category>> get allCategories {
    return categoriesCollection.snapshots().map((list) {
      return list.documents
          .map((doc) =>
              Category(name: doc.data['name'], color: doc.data['color']))
          .toList();
    });
  }

  // streams user's favorite categories
  Stream<List<dynamic>> favCategories(String uid) {
    return usersCollection.document(uid).snapshots().map((doc) {
      return doc.data['fav_categories'];
    });
  }

  // updates favorite categories selection
  Future<void> updateFavCategories(String uid, List favCats) {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .updateData({'fav_categories': favCats});
  }

  // streams all questions in database
  Stream<List<Question>> get allQuestions {
    return questionsCollection.snapshots().map((list) {
      return list.documents
          .map((doc) => Question(
              questionCategories: doc.data['question_categories'],
              text: doc.data['text'],
              id: doc.documentID))
          .toList();
    });
  }

  // streams all active questions for user
  Stream<List<ActiveQuestion>> activeQuestions(String uid) {
    return usersCollection
        .document(uid)
        .collection('active_questions')
        .snapshots()
        .map((list) {
      return list.documents.map((doc) {
        return ActiveQuestion(
            activeChats: doc.data['active_chats'], id: doc.documentID);
      }).toList();
    });
  }

  // streams active chats for specific question
  Stream<List<dynamic>> activeChatsforQ(String qid, String uid) {
    return usersCollection
        .document(uid)
        .collection('active_questions')
        .document(qid)
        .snapshots()
        .map((q) {
      return q.data['active_chats'];
    });
  }

  // partner username from chat
  Future<String> partnerUsername(
      String chatID, String qID, String userID) async {
    // get all users with corresponding id
    QuerySnapshot users = await userNamesCollection.getDocuments();

    var partnerID = '';

    // find partnerID by going into chat
    var chat = await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('chats')
        .document(chatID)
        .get();

    if (chat.data['user1_id'] != userID) {
      partnerID = chat.data['user1_id'];
    } else {
      partnerID = chat.data['user2_id'];
    }

    var partner = users.documents
        .where((element) => element.data['id'] == partnerID)
        .toList();
    return partner[0].documentID;
  }

  // send question answer to active_questions
  Future<void> sendQuestionAnswer(String qid, String uid, double userOpinion) {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection("active_questions")
        .document(qid)
        .setData({"answer": userOpinion}, merge: true);
  }

  // checks if user is in waiting room for specific question
  Future<bool> inWaitingRoom(String qid, String uid) async {
    DocumentSnapshot waitingRoomEntry = await Firestore.instance
        .collection('questions')
        .document(qid)
        .collection('waiting_room')
        .document(uid)
        .get();

    return waitingRoomEntry == null ? false : true;
  }

  // list of questionIDs that are in waiting room for user
  Future<List<String>> unPartneredList(
      List<ActiveQuestion> activeQuestions, String uid) async {
    List<String> unpartneredQsID = [];
    for (var activeQ in activeQuestions) {
      // if question in waiting room, add to
      if (await inWaitingRoom(activeQ.id, uid)) {
        unpartneredQsID.add(activeQ.id);
      }
    }
    return unpartneredQsID;
  }

  // streams all chat messages
  Stream<List<Message>> messagesinChat(String qid, String cid, String uid) {
    return questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((list) {
      return list.documents.map((doc) {
        return Message(
          key: ValueKey(doc.documentID),
          message: doc['text'],
          username: doc['username'],
          isMe: doc['userId'] == uid,
        );
      }).toList();
    });
  }

  // send new message to firebase
  void sendMessage(String qid, String cid, String uid, String username,
      String enteredMessage) async {
    Firestore.instance
        .collection('questions')
        .document(qid)
        .collection('chats')
        .document(cid)
        .collection('messages')
        .add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': uid,
      'username': username,
    });
  }

  // update message counter
  void newMessage(String qid, String cid, String uid) {
    questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .updateData({
      "messageCount": FieldValue.increment(1),
      "${uid}messageCount": FieldValue.increment(1),
    });
  }

  // read messages
  void readMessage(String qid, String cid, String uid) async {
    QuerySnapshot messagesSnapshot = await questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .collection('messages')
        .getDocuments();
    questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .updateData({
      "${uid}messageCount": messagesSnapshot.documents.length,
    });
  }

  // stream for overall message count
  Stream<int> messageCount(String qid, String cid) {
    return questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .snapshots()
        .map((doc) {
      return doc.data["messageCount"] == null ? 0 : doc.data["messageCount"];
    });
  }

  // unread messages counter
  Future<int> unreadMessageCounter(
      String qid, String cid, String uid, int messageC) async {
    DocumentSnapshot messagesSnapshot = await questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .get();

    int m1count = messagesSnapshot.data["${uid}messageCount"] == null
        ? 0
        : messagesSnapshot.data["${uid}messageCount"];
    return messageC - m1count;
  }

  // update partner seen in firebase
  void seenPartner(String qid, String cid, String uid) {
    questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .updateData({
      "${uid}partnerseen": true,
    });
  }

  // check if partner is new
  Future<bool> partnerSeen(String qid, String cid, String uid) async {
    DocumentSnapshot chatSnapshot = await questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .get();

    return chatSnapshot.data["${uid}partnerseen"] == true
        ? chatSnapshot.data["${uid}partnerseen"]
        : false;
  }

  // checks if there are new partners in the question
  Future<bool> doesQNewPartner(
      String qid, String uid, List<dynamic> chats) async {
    for (var cid in chats) {
      if (!await partnerSeen(qid, cid, uid)) {
        return true;
      }
    }
    return false;
  }
}
