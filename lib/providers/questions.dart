// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

// class Questions with ChangeNotifier {
//   List _allQuestions = [];

//   getQuestions() async {
//     try {
//       await Firestore.instance.collection('questions').snapshots(),
//     } catch (exception) {

//     }

//     return StreamBuilder<QuerySnapshot>(
//         stream: Firestore.instance.collection('questions').snapshots(),
//         builder: (ctx, snapshot) {
//           snapshot.data.documents.forEach((doc) {
//             this._allQuestions.add(doc.data);
//           });
//         });
//   }
// }

// await Firestore.instance.collection('questions').getDocuments().then(
//       (QuerySnapshot qs) => {
//         qs.documents.forEach((doc) {
//           this._allQuestions.add(doc.data);
//         })
//       },
//     );
