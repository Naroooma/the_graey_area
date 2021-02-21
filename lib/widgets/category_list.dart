import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/category_list_button.dart';

class CategoryList extends StatefulWidget {
  final catDocs;

  CategoryList(this.catDocs);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('categories')
          .snapshots(), // stream, meaning shows changes
      builder: (ctx, catSnapshot) {
        if (catSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: widget.catDocs.length,
          itemBuilder: (ctx, index) {
            return CategoryListButton(
              widget.catDocs[index],
            );
          },
        );
      },
    );
  }
}
