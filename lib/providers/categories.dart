import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Categories with ChangeNotifier {
  List _pickedCategories = [];
  List _favCategories = [];
  List _allCategories = [];

  get categories async {
    await fetchFavoriteCategories();
    return [..._favCategories];
  }

  get allCategories async {
    await fetchAllCategories();
    return [..._allCategories];
  }

  get pickedCategories {
    return [..._pickedCategories];
  }

  void reset() {
    _pickedCategories = [];
    _favCategories = [];
    _allCategories = [];
  }

  Future<void> fetchAllCategories() async {
    try {
      QuerySnapshot categoriesSnapshot =
          await Firestore.instance.collection('categories').getDocuments();

      categoriesSnapshot.documents.forEach((doc) => {
            if (!_allCategories.contains(doc.data))
              {
                _allCategories.add(doc.data),
              }
          });
    } catch (exception) {
      print("ERROR");
      print(exception);
    }

    // removes duplicates using json
    // _allCategories = _allCategories
    //     .map((item) => jsonEncode(item))
    //     .toSet()
    //     .map((item) => jsonDecode(item))
    //     .toList();
  }

  Future<void> fetchFavoriteCategories() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try {
      DocumentSnapshot favCategories =
          await Firestore.instance.collection('users').document(user.uid).get();

      favCategories['fav_categories'].forEach((cat) => {
            if (!_favCategories.contains(cat))
              {
                _favCategories.add(cat),
              }
          });
    } catch (exception) {
      print("ERROR");
      print(exception);
    }

    // removes duplicates using json
    // _favCategories = _favCategories
    //     .map((item) => jsonEncode(item))
    //     .toSet()
    //     .map((item) => jsonDecode(item))
    //     .toList();
  }

  void addCategory(var value) {
    if (!_pickedCategories.contains(value)) {
      _pickedCategories.add(value);
      notifyListeners();
    }
  }

  void removeCategory(var value) {
    _pickedCategories.removeWhere((item) => item == value);
    notifyListeners();
  }
}
