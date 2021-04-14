import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Questions with ChangeNotifier {
  List _allQuestions = [];
  List _matchQuestions = [];

  Future<List> allQuestions() async {
    await getQuestions();
    return [..._allQuestions];
  }

  List matchQuestions(favCategories) {
    findMatchingQuestions(favCategories);
    return [..._matchQuestions];
  }

  get getAllQuestions {
    return [..._allQuestions];
  }

  get getMatchQuestions {
    return [..._matchQuestions];
  }

  bool isEmpty() {
    if (_allQuestions.isEmpty && this._matchQuestions.isEmpty) {
      return true;
    }
    return false;
  }

  Future<void> getQuestions() async {
    List allQuestions = [];
    try {
      QuerySnapshot questionsSnapshot =
          await Firestore.instance.collection('questions').getDocuments();

      questionsSnapshot.documents.forEach((doc) => {
            if (!allQuestions.contains(doc.data))
              {
                allQuestions.add(doc),
              }
          });
    } catch (exception) {
      print("ERROR");
      print(exception);
    }
    this._allQuestions = allQuestions;
  }

  void findMatchingQuestions(List favCategories) {
    List matchQuestions = [];
    for (final question in _allQuestions) {
      for (final category in question.data['question_categories']) {
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
