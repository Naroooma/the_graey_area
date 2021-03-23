import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

import 'package:auto_size_text/auto_size_text.dart';

class QuestionScreen extends StatefulWidget {
  static const routeName = '/question-screen';

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  var _slidervalue = 50.0;
  @override
  Widget build(BuildContext context) {
    final question = ModalRoute.of(context).settings.arguments as Map;
    final _scaffoldKey = new GlobalKey<ScaffoldState>();
    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => Navigator.of(context).pop(),
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
      ),
      endDrawer: AppDrawer(context),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_screenSize.width / 15),
          child: Column(
            children: [
              Container(
                height: _screenSize.height / 3,
                child: AutoSizeText(
                  question['text'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontFamily:
                        Theme.of(context).textTheme.headline1.fontFamily,
                    fontStyle: FontStyle.italic,
                    fontSize: _screenSize
                        .width, // maximum so that autosize makes is smaller
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Slider(
                min: 0,
                max: 100,
                value: _slidervalue,
                label: _slidervalue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _slidervalue = value;
                  });
                },
                activeColor: Theme.of(context).accentColor,
                inactiveColor: Theme.of(context).accentColor.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        AutoSizeText(
                          "No",
                          style: TextStyle(
                            fontSize: _screenSize.width,
                            color: Theme.of(context).accentColor,
                            fontFamily: Theme.of(context)
                                .textTheme
                                .headline1
                                .fontFamily,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        AutoSizeText(
                          "Yes",
                          style: TextStyle(
                            fontSize: _screenSize.width,
                            color: Theme.of(context).accentColor,
                            fontFamily: Theme.of(context)
                                .textTheme
                                .headline1
                                .fontFamily,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).accentColor),
                  ),
                  onPressed: () {},
                  child: Container(
                      height: 70,
                      width: 70,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                        size: 40,
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
