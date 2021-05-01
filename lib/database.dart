import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_graey_area/models/category.dart';

import 'models/active_question.dart';
import 'models/message.dart';
import 'models/question.dart';

class DatabaseService {
  // users, questions, categories, references
  int counter = 0;
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference questionsCollection =
      Firestore.instance.collection('questions');
  final CollectionReference categoriesCollection =
      Firestore.instance.collection('categories');
  final CollectionReference userNamesCollection =
      Firestore.instance.collection('userNames');

  // void allCateogiresData() {
  //   StreamSubscription allCategoriesListener;
  //   Stream<QuerySnapshot> allCategoriesSnapshot =
  //       categoriesCollection.snapshots();

  //   allCategoriesListener = allCategoriesSnapshot.listen((allCategories) async {
  //     Provider.of<Categories>(context)
  //   });
  // }
  //
  //

  Stream<List<Category>> get allCategories {
    return categoriesCollection.snapshots().map((list) {
      return list.documents
          .map((doc) =>
              Category(name: doc.data['name'], color: doc.data['color']))
          .toList();
    });
  }

  Stream<List<dynamic>> favCategories(String uid) {
    return usersCollection.document(uid).snapshots().map((doc) {
      return doc.data['fav_categories'];
    });
  }

  Future<void> updateFavCategories(String uid, List favCats) {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .updateData({'fav_categories': favCats});
  }

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

  Future<String> partnerUsername(
      String chatID, String qID, String userID) async {
    // get all users with corresponding id
    QuerySnapshot users = await userNamesCollection.getDocuments();

    var partnerID = '';

    // find partnerID by going into chat
    //
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

  Future<void> sendQuestionAnswer(String qid, String uid, double userOpinion) {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection("active_questions")
        .document(qid)
        .setData({"answer": userOpinion}, merge: true);
  }

  Future<bool> inWaitingRoom(String qid, String uid) async {
    DocumentSnapshot waitingRoomEntry = await Firestore.instance
        .collection('questions')
        .document(qid)
        .collection('waiting_room')
        .document(uid)
        .get();

    return waitingRoomEntry == null ? false : true;
  }

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

  // total unread messages in a specific question
  // Stream<dynamic> totalMessagesForQ(
  //     String qid, String uid, List<dynamic> chats) {
  //   List<Stream> l = [];
  //   //counter = await unreadMessageCounter(qid, cid, uid, data)

  //   // for loop to open all streams
  //   for (var cid in chats) {
  //     // ignore: cancel_subscriptions
  //     l.add(messageCount(qid, cid));
  //   }
  //   return StreamGroup.merge(l);
  // }

  // Future<int> totalreadMessagesForQ(
  //     String qid, String uid, List<dynamic> chats) async {
  //   int counter = 0;
  //   for (var cid in chats) {
  //     // ignore: cancel_subscriptions
  //     DocumentSnapshot messagesSnapshot = await questionsCollection
  //         .document(qid)
  //         .collection('chats')
  //         .document(cid)
  //         .get();

  //     int m1count = messagesSnapshot.data["${uid}messageCount"] == null
  //         ? 0
  //         : messagesSnapshot.data["${uid}messageCount"];

  //     counter += m1count;
  //   }
  //   return counter;
  // }

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

  Future<void> doesQNewPartner(
      String qid, String uid, List<dynamic> chats) async {
    for (var cid in chats) {
      if (!await partnerSeen(qid, cid, uid)) {
        return true;
      }
    }
  }

  // check if user half answered specific question, if so return first answer

  // check if searching for partner in specific question

}
