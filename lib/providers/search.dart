import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Search with ChangeNotifier {
  String query = "";
  bool searchActive = false;
}
