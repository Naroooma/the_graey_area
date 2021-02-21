import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../providers/categories.dart';

class CategoryListButton extends StatefulWidget {
  final catDoc;

  CategoryListButton(this.catDoc);

  @override
  _CategoryListButtonState createState() => _CategoryListButtonState();
}

class _CategoryListButtonState extends State<CategoryListButton> {
  bool _selection = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HexColor(widget.catDoc['color']).withOpacity(0.8),
      child: InkResponse(
        onTap: () {
          setState(() {
            _selection = !_selection;
            if (_selection == true) {
              Provider.of<Categories>(context, listen: false)
                  .addCategory(widget.catDoc['name']);
            } else {
              Provider.of<Categories>(context, listen: false)
                  .removeCategory(widget.catDoc['name']);
            }
            print(_selection);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border:
                _selection ? Border.all(width: 5, color: Colors.white) : null,
          ),
          height: 60,
          padding: EdgeInsets.all(5),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                widget.catDoc['name'],
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontFamily: "PT_Serif",
                  fontSize: 100, // max size,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
