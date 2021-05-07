import 'package:flutter/material.dart';

class Categories with ChangeNotifier {
  List _favCategories = [];

  get getFavCategories {
    return [..._favCategories];
  }

  void reset() {
    _favCategories = [];
  }

  void initCategory(List init) {
    if (init != null) {
      this._favCategories = init;
    }
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

  bool inCategory(var value) {
    return _favCategories.contains(value);
  }
}
