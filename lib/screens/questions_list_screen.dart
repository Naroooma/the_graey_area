import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/questions.dart';
import 'package:the_graey_area/providers/search.dart';

import '../widgets/question_tile.dart';
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
  bool _force = false;

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
    // if at least one of the providers are empty or force => fetchData
    if (Provider.of<Questions>(context, listen: false).isEmpty() ||
        Provider.of<Categories>(context, listen: false).isEmpty() ||
        _force) {
      await fetchData();
      _force = false;
    } else {
      // if providers are not empty => put provider data into local variables
      favCategories =
          Provider.of<Categories>(context, listen: false).getFavCategories;
      allCategories =
          Provider.of<Categories>(context, listen: false).getAllCategories;
      _allQuestions =
          Provider.of<Questions>(context, listen: false).getAllQuestions;
      _matchQuestions =
          Provider.of<Questions>(context, listen: false).getMatchQuestions;
    }
  }

  Future<void> fetchData() async {
    favCategories =
        await Provider.of<Categories>(context, listen: false).favCategories();
    allCategories =
        await Provider.of<Categories>(context, listen: false).allCategories();
    _allQuestions =
        await Provider.of<Questions>(context, listen: false).allQuestions();
    _matchQuestions = Provider.of<Questions>(context, listen: false)
        .matchQuestions(favCategories);

    _force = false;
  }

  @override
  Widget build(BuildContext context) {
    _allQuestions =
        Provider.of<Questions>(context, listen: false).getAllQuestions;
    favCategories =
        Provider.of<Categories>(context, listen: false).getFavCategories;
    allCategories =
        Provider.of<Categories>(context, listen: false).getAllCategories;
    _matchQuestions =
        Provider.of<Questions>(context, listen: false).getMatchQuestions;

    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
          setState(() {
            _force = true;
          });
        }, // don't call getData because of FutureBuilder
        child: Center(
            child: Provider.of<Questions>(context, listen: false).isEmpty() ||
                    Provider.of<Categories>(context, listen: false).isEmpty() ||
                    _force
                ? FutureBuilder(
                    // gets all the questions
                    future: fetchData(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        if (!_searchActive) {
                          return ListView.builder(
                              itemCount: _matchQuestions.length,
                              itemBuilder: (ctx, index) {
                                return QuestionTile(
                                    _matchQuestions[index], allCategories);
                              });
                        } else {
                          print('Building Search Results');
                          return _buildSearchResults();
                        }
                      }
                    },
                  )
                : ListView.builder(
                    itemCount: _matchQuestions.length,
                    itemBuilder: (ctx, index) {
                      return QuestionTile(
                          _matchQuestions[index], allCategories);
                    })),
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
