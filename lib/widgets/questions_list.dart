import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/category.dart';
import 'package:the_graey_area/widgets/question_tile.dart';

class QuestionsList extends StatefulWidget {
  List matchQuestions;

  QuestionsList(this.matchQuestions);

  @override
  _QuestionsListState createState() => _QuestionsListState();
}

class _QuestionsListState extends State<QuestionsList> {
  @override
  Widget build(BuildContext context) {
    List<Category> allCategories = Provider.of<List<Category>>(context);

    return Column(
      children: [
        TextField(),
        Center(
          child: ListView.builder(
            itemCount: widget.matchQuestions.length,
            itemBuilder: (ctx, index) {
              return QuestionTile(widget.matchQuestions[index], allCategories);
            },
          ),
        ),
      ],
    );
  }
}
