import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_graey_area/models/category.dart';
import 'dart:async';

import 'models/active_question.dart';
import 'models/question.dart';

class DatabaseService {
  // users, questions, categories, references
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

  // send message
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

  // unread messages counter
  Future<void> unreadMessageCounter(String qid, String cid, String uid) async {
    DocumentSnapshot messagesSnapshot = await questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .get();
    int mcount = messagesSnapshot.data["messageCount"] == null
        ? 0
        : messagesSnapshot.data["messageCount"];
    ;
    int m1count = messagesSnapshot.data["${uid}messageCount"] == null
        ? 0
        : messagesSnapshot.data["${uid}messageCount"];
    return mcount - m1count;
  }

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
  Future<void> isNewPartner(String qid, String cid, String uid) async {
    DocumentSnapshot chatSnapshot = await questionsCollection
        .document(qid)
        .collection('chats')
        .document(cid)
        .get();

    return chatSnapshot.data["${uid}partnerseen"] == true
        ? chatSnapshot.data["${uid}partnerseen"]
        : false;
  }

  // stream for all active questions that shows changes

  // check if user half answered specific question, if so return first answer

  // check if searching for partner in specific question

}
