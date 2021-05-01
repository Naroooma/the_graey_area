import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../providers/categories.dart';

// ignore: must_be_immutable
class CategoryListButton extends StatefulWidget {
  final catDoc;

  CategoryListButton(this.catDoc);

  @override
  _CategoryListButtonState createState() => _CategoryListButtonState();
}

class _CategoryListButtonState extends State<CategoryListButton> {
  @override
  Widget build(BuildContext context) {
    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    return Material(
      color: HexColor(widget.catDoc.color).withOpacity(0.8),
      child: InkResponse(
        onTap: () {
          setState(() {
            if (Provider.of<Categories>(context, listen: false)
                    .inCategory(widget.catDoc.name) ==
                false) {
              Provider.of<Categories>(context, listen: false)
                  .addCategory(widget.catDoc.name);
            } else {
              Provider.of<Categories>(context, listen: false)
                  .removeCategory(widget.catDoc.name);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Provider.of<Categories>(context, listen: false)
                    .inCategory(widget.catDoc.name)
                ? Border.all(width: _screenwidth * 0.01, color: Colors.white)
                : null,
          ),
          height: _screenheight * 0.075,
          padding: EdgeInsets.all(_screenheight * 0.007),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                widget.catDoc.name,
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
