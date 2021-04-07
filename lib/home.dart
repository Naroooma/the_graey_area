import 'package:flutter/material.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';
import 'package:the_graey_area/screens/questions_list_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool showFab = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 1, length: 2);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "The Græy Area",
          style: TextStyle(
            fontFamily: 'PT_Serif',
            color: Theme.of(context).primaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Theme.of(context).accentColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        elevation: 0.7,
        bottom: TabBar(
          labelColor: Theme.of(context).primaryColor,
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.add)),
            Tab(icon: Icon(Icons.question_answer)),
          ],
        ),
        actions: <Widget>[
          Icon(Icons.search),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          Icon(Icons.more_vert)
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          QuestionsListScreen(),
          QuestionsChatScreen(),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () => print("open chats"),
            )
          : null,
    );
  }
}
