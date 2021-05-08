import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/category.dart';

import './category_list_button.dart';

class CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<dynamic> allCategories = Provider.of<List<Category>>(context);
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: allCategories.length,
      itemBuilder: (ctx, index) {
        return CategoryListButton(allCategories[index]);
      },
    );
  }
}
