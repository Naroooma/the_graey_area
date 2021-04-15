import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Questions with ChangeNotifier {
  List _matchQuestions = [];

  List matchQuestions(favCategories, allQuestions) {
    findMatchingQuestions(favCategories, allQuestions);
    return [..._matchQuestions];
  }

  get getMatchQuestions {
    return [..._matchQuestions];
  }

  bool isEmpty() {
    if (this._matchQuestions.isEmpty) {
      return true;
    }
    return false;
  }

  void findMatchingQuestions(List favCategories, List allQuestions) {
    List matchQuestions = [];
    for (final question in allQuestions) {
      for (final category in question.questionCategories) {
        if (favCategories.contains(category)) {
          matchQuestions.add(question);
          break;
        }
      }
    }

    // removes duplicates using json
    // matchQuestions = matchQuestions
    //     .map((item) => jsonEncode(item))
    //     .toSet()
    //     .map((item) => jsonDecode(item))
    //     .toList();
    this._matchQuestions = matchQuestions;
  }
}
