import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Search with ChangeNotifier {
  String query = "";
  bool searchActive = false;

  void editQuery(text) {
    this.query = text;
    notifyListeners();
  }

  void reset() {
    this.query = "";
  }
}
