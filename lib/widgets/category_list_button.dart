import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../providers/categories.dart';

// ignore: must_be_immutable
class CategoryListButton extends StatefulWidget {
  final catDoc;
  bool _selection;

  CategoryListButton(this.catDoc, this._selection);

  @override
  _CategoryListButtonState createState() => _CategoryListButtonState();
}

class _CategoryListButtonState extends State<CategoryListButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: HexColor(widget.catDoc['color']).withOpacity(0.8),
      child: InkResponse(
        onTap: () {
          setState(() {
            widget._selection = !widget._selection;
            if (widget._selection == true) {
              Provider.of<Categories>(context, listen: false)
                  .addCategory(widget.catDoc['name']);
            } else {
              Provider.of<Categories>(context, listen: false)
                  .removeCategory(widget.catDoc['name']);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: widget._selection
                ? Border.all(width: 5, color: Colors.white)
                : null,
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
