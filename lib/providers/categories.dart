import 'package:flutter/material.dart';

class Categories with ChangeNotifier {
  // start _favCategories to be equal to firebase favCategories
  List _favCategories = [];
  bool catExist = false;

  get getFavCategories {
    return [..._favCategories];
  }

  void reset() {
    _favCategories = [];
  }

  void initCategory(List init) {
    this._favCategories = init;
  }

  void addCategory(var value) {
    if (!_favCategories.contains(value)) {
      _favCategories.add(value);
      notifyListeners();
    }
  }

  void removeCategory(var value) {
    _favCategories.removeWhere((item) => item == value);
    notifyListeners();
  }
}
