import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../providers/categories.dart';

// ignore: must_be_immutable
class CategoryListButton extends StatefulWidget {
  final category;

  CategoryListButton(this.category);

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
      color: HexColor(widget.category.color).withOpacity(0.8),
      child: InkResponse(
        onTap: () {
          setState(() {
            if (Provider.of<Categories>(context, listen: false)
                    .inCategory(widget.category.name) ==
                false) {
              Provider.of<Categories>(context, listen: false)
                  .addCategory(widget.category.name);
            } else {
              Provider.of<Categories>(context, listen: false)
                  .removeCategory(widget.category.name);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Provider.of<Categories>(context, listen: false)
                    .inCategory(widget.category.name)
                ? Border.all(width: _screenwidth * 0.01, color: Colors.white)
                : null,
          ),
          height: _screenheight * 0.075,
          padding: EdgeInsets.all(_screenheight * 0.007),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                widget.category.name,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontFamily: "PT_Serif",
                  fontSize: _screenheight * 1, // max size (fits to boundaries)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
