import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/category.dart';
import 'package:the_graey_area/models/question.dart';
import 'package:the_graey_area/providers/auth.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';

import '../database.dart';
import '../widgets/question_tile.dart';
import 'questions_chats_screen.dart';

class QuestionsListScreen extends StatefulWidget {
  static const routeName = '/questions-list-screen';

  final List<String> list = List.generate(10, (index) => "Text $index");

  @override
  _QuestionsListScreenState createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  List<dynamic> allQuestions = [];
  List<dynamic> favCategories = [];
  List<dynamic> allCategories = [];
  List<dynamic> matchQuestions = [];

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _force = false;

  bool _searchActive = false;
  String query = "";
  final TextEditingController _filter = new TextEditingController();

  void rebuild(dynamic a) {
    if (a == 'from back') {
      setState(() {});
    }
  }

  AppBar buildSearchBar(_screenheight, _screenwidth) {
    _filter.addListener(() {
      setState(() {
        query = _filter.text;
      });
    });
    return AppBar(
      backgroundColor: Colors.grey[300],
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      title: Container(
        height: _screenheight * 0.05,
        child: TextField(
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: _screenheight * 0.015,
              color: Theme.of(context).accentColor),
          decoration: InputDecoration(
            labelText: 'Search for Questions',
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
          size: _screenheight * 0.035,
          color: Theme.of(context).primaryColor,
        ),
      ),
      actions: [
        SizedBox(
          width: _screenheight * 0.015,
        ),
        GestureDetector(
          child: Icon(Icons.menu,
              size: _screenheight * 0.035), // change this size and style
          onTap: () => _scaffoldKey.currentState.openEndDrawer(),
        ),
        SizedBox(
          width: _screenheight * 0.025,
        ),
      ],
    );
  }

  List<dynamic> findMatchingQuestions(List favCategories, List allQuestions) {
    List matchQuestions = [];
    for (final question in allQuestions) {
      for (final category in question.questionCategories) {
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

  List _buildSearchResults() {
    List<dynamic> suggestionList = [];
    query.isEmpty
        ? suggestionList = matchQuestions
        : suggestionList.addAll(
            allQuestions.where((question) {
              return question.text.toLowerCase().contains(query.toLowerCase());
            }),
          );

    return suggestionList;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<Auth>(context).user;

    allQuestions = Provider.of<List<Question>>(context);
    allCategories = Provider.of<List<Category>>(context);

    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    // if user has logged out, close stream

    return Scaffold(
      appBar: _searchActive
          ? buildSearchBar(_screenheight, _screenwidth)
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                "Questions",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'PT_Serif'),
              ),
              backgroundColor: Colors.grey[300],
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
              ),
              actions: [
                SizedBox(
                  width: _screenheight * 0.025,
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
                  child: Icon(Icons.search, size: _screenheight * 0.035),
                ),
                SizedBox(
                  width: _screenheight * 0.025,
                ),
                GestureDetector(
                  child: Icon(Icons.menu,
                      size:
                          _screenheight * 0.035), // change this size and style
                  onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                ),
                SizedBox(
                  width: _screenheight * 0.025,
                ),
              ],
            ),
      endDrawer: AppDrawer(context),
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.message,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () => Navigator.pushReplacementNamed(
              context, QuestionsChatsScreen.routeName)
          // .then((value) => rebuild(value)),
          ),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async {
          setState(() {
            _force = true;
          });
        }, // don't call getData because of FutureBuilder
        child: StreamBuilder(
          stream:
              Provider.of<DatabaseService>(context).activeQuestions(user.uid),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }
            //
            if (snapshot.data == null) {
              return CircularProgressIndicator();
            }
            List activeQuestions = snapshot.data;
            allQuestions = allQuestions
                .where((doc) =>
                    !activeQuestions.any((element) => element.id == doc.id))
                .toList();
            return StreamBuilder(
              stream:
                  Provider.of<DatabaseService>(context).favCategories(user.uid),
              builder: (context, favCategories) {
                // if (favCategories.connectionState == ConnectionState.waiting) {
                //   return Center(child: CircularProgressIndicator());
                // }
                if (favCategories.data == null) {
                  return CircularProgressIndicator();
                }
                matchQuestions =
                    findMatchingQuestions(favCategories.data, allQuestions);

                List searchQuestions;
                if (_searchActive) {
                  searchQuestions = _buildSearchResults();
                }
                return Center(
                  child: ListView.builder(
                    itemCount: _searchActive
                        ? searchQuestions.length
                        : matchQuestions.length,
                    itemBuilder: (ctx, index) {
                      return QuestionTile(
                          _searchActive
                              ? searchQuestions[index]
                              : matchQuestions[index],
                          allCategories);
                    },
                  ),
                );
              },
            );
          },
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
