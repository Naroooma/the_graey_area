import 'package:flutter/material.dart';

import './category_list_button.dart';

class CategoryList extends StatefulWidget {
  final allCategories;
  final favCategories;

  CategoryList(this.favCategories, this.allCategories);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // padding: EdgeInsets.all(0),
      itemCount: widget.allCategories.length,
      itemBuilder: (ctx, index) {
        bool selection = false;

        if (widget.favCategories != null &&
            widget.favCategories.contains(widget.allCategories[index].name)) {
          selection = true;
        }

        return CategoryListButton(widget.allCategories[index], selection);
      },
    );
  }
}
