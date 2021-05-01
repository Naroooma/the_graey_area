import 'package:flutter/material.dart';

import './category_list_button.dart';

class CategoryList extends StatelessWidget {
  final allCategories;
  final favCategories;

  CategoryList(this.favCategories, this.allCategories);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: allCategories.length,
      itemBuilder: (ctx, index) {
        return CategoryListButton(allCategories[index]);
      },
    );
  }
}
