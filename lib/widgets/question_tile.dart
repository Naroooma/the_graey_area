import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:the_graey_area/screens/question_screen.dart';

class QuestionTile extends StatelessWidget {
  final _question;
  final List allCategories;

  QuestionTile(this._question, this.allCategories);

  Color correspondingColor(List<dynamic> _allCategories, String categoryName) {
    var color;
    var matched = _allCategories.where((item) => item.name == categoryName);
    matched.forEach((item) {
      color = HexColor(item.color);
    });
    return color;
  }

  @override
  Widget build(BuildContext context) {
    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(QuestionScreen.routeName, arguments: _question);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
            vertical: _screenheight * 0.009, horizontal: _screenwidth * 0.025),
        child: Column(
          children: [
            Container(
              height: _screenheight * 0.11,
              padding: EdgeInsets.all(_screenheight * 0.015),
              alignment: Alignment.center,
              child: AutoSizeText(
                _question.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'PT_Serif',
                  fontStyle: FontStyle.italic,
                  fontSize: _screenheight * 1, // max size (fits to boundaries)
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(_screenheight * 0.01),
              child: Wrap(
                  spacing: _screenheight * 0.025,
                  children: List<Widget>.generate(
                    _question.questionCategories.length,
                    (int index) {
                      return Chip(
                        backgroundColor: correspondingColor(allCategories,
                                _question.questionCategories[index])
                            .withOpacity(0.8),
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        label: Text(
                          _question.questionCategories[index],
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
