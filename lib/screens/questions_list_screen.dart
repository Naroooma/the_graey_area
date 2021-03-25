import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../widgets/question_tile.dart';
import '../widgets/app_drawer.dart';
import '../providers/categories.dart';

class QuestionsListScreen extends StatefulWidget {
  final List<String> list = List.generate(10, (index) => "Text $index");

  @override
  _QuestionsListScreenState createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  List<dynamic> _allQuestions = [];
  List<dynamic> favCategories = [];
  List<dynamic> allCategories = [];
  List<dynamic> _matchQuestions = [];

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _force = true;

  bool _searchActive = false;
  String query = "";
  final TextEditingController _filter = new TextEditingController();

  AppBar buildSearchBar() {
    return AppBar(
      backgroundColor: Theme.of(context).accentColor,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      title: Container(
        height: 40,
        child: TextField(
          style: TextStyle(fontSize: 14, color: Theme.of(context).accentColor),
          decoration: InputDecoration(
            labelText: 'Search Questions or Categories',
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          controller: _filter,
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          setState(() {
            _filter.clear();
            _searchActive = !_searchActive;
          });
        },
        child: Icon(
          Icons.arrow_back,
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
      ),
      actions: [
        GestureDetector(
          child: Icon(Icons.menu, size: 30), // change this size and style
          onTap: () => _scaffoldKey.currentState.openEndDrawer(),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    _filter.addListener(() {
      print(_filter.text);
      setState(() {
        query = _filter.text;
      });
    });
    List<dynamic> suggestionList = [];
    query.isEmpty
        ? suggestionList = _matchQuestions
        : suggestionList.addAll(
            _allQuestions.where((question) {
              return question['text']
                  .toLowerCase()
                  .contains(query.toLowerCase());
            }),
          );

    return Container(
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (ctx, index) {
          return QuestionTile(suggestionList[index], allCategories);
        },
      ),
    );
  }

  Future<void> getData() async {
    if ((_matchQuestions == null && allCategories == null) || _force) {
      print('fetching data...');
      favCategories =
          await Provider.of<Categories>(context, listen: false).categories;
      allCategories =
          await Provider.of<Categories>(context, listen: false).allCategories;
      _allQuestions = await getQuestions();
      _matchQuestions = findMatchingQuestions();
    }
    _force = false;
  }

  Future<List> getQuestions() async {
    List allQuestions = [];
    try {
      QuerySnapshot questionsSnapshot =
          await Firestore.instance.collection('questions').getDocuments();

      questionsSnapshot.documents.forEach((doc) => {
            if (!allQuestions.contains(doc.data))
              {
                allQuestions.add(doc),
              }
          });
    } catch (exception) {
      print("ERROR");
      print(exception);
    }

    // removes duplicates using json
    // allQuestions = allQuestions
    //     .map((item) => jsonEncode(item))
    //     .toSet()
    //     .map((item) => jsonDecode(item))
    //     .toList();
    return allQuestions;
  }

  List findMatchingQuestions() {
    List matchQuestions = [];
    for (final question in _allQuestions) {
      for (final category in question.data['question_categories']) {
        if (favCategories.contains(category)) {
          matchQuestions.add(question);

          break;
        }
      }
    }

    // removes duplicates using json
    // matchQuestions = matchQuestions
    //     .map((item) => jsonEncode(item))
    //     .toSet()
    //     .map((item) => jsonDecode(item))
    //     .toList();
    return matchQuestions;
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    print(_screenSize.width);

    return Scaffold(
      key: _scaffoldKey,
      appBar: _searchActive
          ? buildSearchBar()
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                "Questions",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'PT_Serif'),
              ),
              backgroundColor: Theme.of(context).accentColor,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
              ),
              actions: [
                SizedBox(
                  width: _screenSize.width / 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchActive = !_searchActive;
                    });
                    // showSearch(
                    //     context: context,
                    //     delegate:
                    //         Search(_allQuestions, _matchQuestions, allCategories));
                  },
                  child: Icon(Icons.search, size: 30),
                ),
                SizedBox(
                  width: _screenSize.width / 20,
                ),
                GestureDetector(
                  child: Icon(Icons.mail_outline, size: 30),
                ),
                SizedBox(
                  width: _screenSize.width / 20,
                ),
                GestureDetector(
                  child:
                      Icon(Icons.menu, size: 30), // change this size and style
                  onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                ),
                SizedBox(
                  width: _screenSize.width / 20,
                ),
              ],
            ),
      endDrawer: AppDrawer(context),
      backgroundColor: Theme.of(context).primaryColor,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
          setState(() {
            _force = true;
          });
        }, // don't call getData because of FutureBuilder
        child: Center(
          child: FutureBuilder(
            // gets all the questions
            future: getData(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (!_searchActive) {
                  return ListView.builder(
                    itemCount: _matchQuestions.length,
                    itemBuilder: (ctx, index) {
                      print(_matchQuestions[index]);
                      return QuestionTile(
                          _matchQuestions[index], allCategories);
                    },
                  );
                } else {
                  print('Building Search Results');
                  return _buildSearchResults();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

// class Search extends SearchDelegate {
//   final List<dynamic> allQuestions;
//   final List<dynamic> matchQuestions;
//   final List<dynamic> allCategories;

//   Search(this.allQuestions, this.matchQuestions, this.allCategories);

//   @override
//   // TODO: implement searchFieldLabel
//   String get searchFieldLabel => "Search Questions and Categories";

//   @override
//   // TODO: implement searchFieldStyle
//   TextStyle get searchFieldStyle => TextStyle(fontSize: 15);

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     // TODO: implement appBarTheme
//     return ThemeData(
//       primaryColor: Colors.grey[50],
//       primaryIconTheme: IconThemeData(
//         color: Colors.grey[50],
//       ),
//     );
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.close),
//         onPressed: () {
//           query = "";
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//   }

//   String selectedResult;

//   @override
//   Widget buildResults(BuildContext context) {
//     return Container(
//       child: Center(
//         child: Text(selectedResult),
//       ),
//     );
//   }

//   List<String> recentList = [];

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<dynamic> suggestionList = [];
//     query.isEmpty
//         ? suggestionList = matchQuestions
//         : suggestionList.addAll(
//             allQuestions.where((question) {
//               print(question['text']);
//               return question['text']
//                   .toLowerCase()
//                   .contains(query.toLowerCase());
//             }),
//           );

//     return Container(
//       color: Theme.of(context).primaryColor,
//       child: ListView.builder(
//         itemCount: suggestionList.length,
//         itemBuilder: (ctx, index) {
//           return QuestionTile(suggestionList[index], allCategories);
//         },
//       ),
//     );
//   }
// }
