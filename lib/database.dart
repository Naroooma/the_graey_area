import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_graey_area/models/category.dart';
import 'dart:async';

import 'providers/categories.dart';

class DatabaseService {
  // users, questions, categories, references
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference questionsCollection =
      Firestore.instance.collection('questions');
  final CollectionReference categoriesCollection =
      Firestore.instance.collection('categories');

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
}
