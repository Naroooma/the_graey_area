import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/auth.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';

import '../database.dart';
import '../widgets/category/category_list.dart';
import '../providers/categories.dart';

class CategoryPickerScreen extends StatelessWidget {
  static const routeName = '/category-picker-screen';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context).user;

    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: StreamBuilder(
          stream: DatabaseService().favCategories(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              // initialize provider to match favCategories from firebase
              Provider.of<Categories>(context, listen: false)
                  .initCategory(snapshot.data);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _screenheight * 0.08,
                  ),
                  Text(
                    "Let's Talk About",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontFamily: 'PT_Serif',
                      fontStyle: FontStyle.italic,
                      fontSize: _screenheight * 0.09,
                    ),
                  ),
                  Consumer<Categories>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _screenwidth * 0.02,
                              vertical: _screenheight * 0.01,
                            ),
                            child: Text(
                              provider.getFavCategories.length < 3
                                  ? "Pick at least 3 categories you are interested in"
                                  : "You have picked ${provider.getFavCategories.length} categories",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontFamily: 'PT_Serif',
                                fontSize: _screenheight * 0.025,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            child: Text('Next'),
                            onPressed: () async {
                              if (provider.getFavCategories.length < 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Select At Least 3 Categories"),
                                    backgroundColor:
                                        Theme.of(context).errorColor,
                                  ),
                                );
                              } else {
                                await DatabaseService().updateFavCategories(
                                    user.uid, provider.getFavCategories);

                                Navigator.pushNamed(
                                    context, QuestionsChatsScreen.routeName);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[600],
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).accentColor,
                              ),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: _screenheight * 0.02,
                  ),
                  Expanded(
                    child: CategoryList(),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
