import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReqAutoText extends StatelessWidget {
  String text;
  Size screenSize;
  double containerHeight;

  ReqAutoText(this.text, this.screenSize, this.containerHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      child: AutoSizeText(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).accentColor,
          fontFamily: Theme.of(context).textTheme.headline1.fontFamily,
          fontStyle: FontStyle.italic,
          fontSize:
              screenSize.width, // maximum so that autosize makes is smaller
        ),
      ),
    );
  }
}
