// listview of all active questions, with small preview of new chats
// navigation to new questions

import 'package:flutter/material.dart';
import 'package:the_graey_area/screens/questions_list_screen.dart';
import 'package:the_graey_area/widgets/app_drawer.dart';

class QuestionsChatsScreen extends StatefulWidget {
  static const routeName = '/questions-chats-screen';

  @override
  _QuestionsChatsScreenState createState() => _QuestionsChatsScreenState();
}

class _QuestionsChatsScreenState extends State<QuestionsChatsScreen> {
  final dummyData = [
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 2},
    {'question': "MY NAME IS ITAIIIII", 'unanswered': 0}
  ];

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: _searchActive
      //     ? buildSearchBar()
      //    :
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Chats",
          style: TextStyle(
              color: Theme.of(context).primaryColor, fontFamily: 'PT_Serif'),
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
              // setState(() {
              //   _searchActive = !_searchActive;
              //   print(_searchActive);
              // });
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
            child: Icon(Icons.menu, size: 30), // change this size and style
            onTap: () => _scaffoldKey.currentState.openEndDrawer(),
          ),
          SizedBox(
            width: _screenSize.width / 20,
          ),
        ],
      ),
      endDrawer: AppDrawer(context),
      backgroundColor: Colors.grey[300],
      key: _scaffoldKey,
      body: ListView.builder(
        itemCount: dummyData.length,
        itemBuilder: (context, i) => Column(
          children: [
            Divider(
              height: 10.0,
            ),
            ListTile(
              title: Text(
                dummyData[i]['question'],
                style: TextStyle(fontFamily: 'PT_Serif'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
        onPressed: () => Navigator.pushReplacementNamed(
            context, QuestionsListScreen.routeName),
      ),
    );
  }
}
