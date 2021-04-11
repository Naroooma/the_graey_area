import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';
import 'package:the_graey_area/screens/questions_list_screen.dart';

import './widgets/app_drawer.dart';
import 'providers/search.dart';

class Home extends StatefulWidget {
  static const routeName = '/home-screen';

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

  String query = "";
  final TextEditingController _filter = new TextEditingController();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

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
            Provider.of<Search>(context, listen: false).searchActive =
                !Provider.of<Search>(context, listen: false).searchActive;
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

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    Provider.of<Search>(context, listen: false).reset();

    _filter.addListener(() {
      Provider.of<Search>(context, listen: false).editQuery(_filter.text);
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: Provider.of<Search>(context, listen: false).searchActive
          ? buildSearchBar()
          : AppBar(
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
                  Tab(icon: Icon(Icons.question_answer)),
                  Tab(icon: Icon(Icons.add)),
                ],
              ),
              actions: [
                SizedBox(
                  width: _screenSize.width / 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      Provider.of<Search>(context, listen: false).searchActive =
                          !Provider.of<Search>(context, listen: false)
                              .searchActive;
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
      body: !Provider.of<Search>(context, listen: false).searchActive
          ? TabBarView(
              controller: _tabController,
              children: <Widget>[
                QuestionsChatsScreen(),
                QuestionsListScreen(),
              ],
            )
          : _tabController.index == 1
              ? QuestionsListScreen()
              : QuestionsChatsScreen(),
    );
  }
}
