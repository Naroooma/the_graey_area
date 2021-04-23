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
    print('ALL CATEGORIES STREAM');
    return categoriesCollection.snapshots().map((list) {
      return list.documents
          .map((doc) =>
              Category(name: doc.data['name'], color: doc.data['color']))
          .toList();
    });
  }

  Stream<List<dynamic>> favCategories(String uid) {
    print('FAV CATEGORIES STREAM');
    return usersCollection.document(uid).snapshots().map((doc) {
      return doc.data['fav_categories'];
    });
  }

  Stream<List<Question>> get allQuestions {
    print('ALL QUESTIONS STREAM');
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
    print('ACTIVE QUESTIONS STREAM');
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
    print(partner);
    return partner[0].documentID;
  }
}
