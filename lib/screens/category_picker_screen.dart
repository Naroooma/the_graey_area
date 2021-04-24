import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/models/category.dart';
import 'package:the_graey_area/screens/questions_chats_screen.dart';

import '../database.dart';
import '../widgets/category_button.dart';
import '../widgets/category_list.dart';
import '../providers/categories.dart';

class CategoryPickerScreen extends StatelessWidget {
  static const routeName = '/category-picker-screen';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    List<dynamic> allCategories = Provider.of<List<Category>>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        // if user has logged out, close stream
        child: user == null || user.uid == null
            ? CircularProgressIndicator()
            : StreamBuilder<Object>(
                stream: Provider.of<DatabaseService>(context)
                    .favCategories(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          "Let's Talk About",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontFamily: 'PT_Serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 75,
                          ),
                        ),
                        Consumer<Categories>(
                          builder: (context, provider, child) {
                            // initialize provider to match favCategories from firebase
                            provider.initCategory(snapshot.data);
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    provider.getFavCategories.length < 3
                                        ? "Pick at least 3 categories you are interested in"
                                        : "You have picked ${provider.getFavCategories.length} categories",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontFamily: 'PT_Serif',
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text('Next'),
                                  onPressed: () async {
                                    if (provider.getFavCategories.length < 3) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Select At Least 3 Categories"),
                                          backgroundColor:
                                              Theme.of(context).errorColor,
                                        ),
                                      );
                                    } else {
                                      FirebaseUser user = await FirebaseAuth
                                          .instance
                                          .currentUser();

                                      await Firestore.instance
                                          .collection('users')
                                          .document(user.uid)
                                          .updateData({
                                        'fav_categories':
                                            provider.getFavCategories
                                      });

                                      Navigator.pushNamed(context,
                                          QuestionsChatsScreen.routeName);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.grey[600],
                                    ),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Theme.of(context).accentColor,
                                    ),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Expanded(
                          child: CategoryList(
                            snapshot.data,
                            allCategories,
                            /* child: Stack(
                            children: [
                              SizedBox(
                                height: 700,
                                width: 350,
                              ),
                              Positioned(
                                top: 10,
                                child: CategoryButton(
                                  text: 'Economics',
                                  color: Colors.lightBlue[200],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                left: 125,
                                top: 50,
                                child: CategoryButton(
                                  text: 'Politics',
                                  color: Colors.limeAccent[200],
                                  size: 100,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 20,
                                child: CategoryButton(
                                  text: 'U.S.A',
                                  color: Colors.red,
                                  size: 115,
                                ),
                              ),
                              Positioned(
                                left: 40,
                                top: 135,
                                child: CategoryButton(
                                  text: 'Philosophy',
                                  color: Colors.greenAccent[400],
                                  size: 115,
                                ),
                              ),
                              Positioned(
                                right: 40,
                                top: 140,
                                child: CategoryButton(
                                  text: 'Middle East',
                                  color: Colors.orange[400],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                left: 105,
                                top: 240,
                                child: CategoryButton(
                                  text: 'Global',
                                  color: Colors.orange[800],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                top: 270,
                                child: CategoryButton(
                                  text: 'Health',
                                  color: Colors.yellow[400],
                                  size: 100,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 270,
                                child: CategoryButton(
                                  text: 'Ethics',
                                  color: Colors.deepPurple[500],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                left: 55,
                                top: 360,
                                child: CategoryButton(
                                  text: 'Culture',
                                  color: Colors.blueAccent[700],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                right: 40,
                                top: 400,
                                child: CategoryButton(
                                  text: 'Technology',
                                  color: Colors.purpleAccent,
                                  size: 130,
                                ),
                              ),
                              Positioned(
                                top: 480,
                                child: CategoryButton(
                                  text: 'Europe',
                                  color: Colors.redAccent[700],
                                  size: 120,
                                ),
                              ),
                              Positioned(
                                left: 120,
                                top: 530,
                                child: CategoryButton(
                                  text: 'Sport',
                                  color: Colors.teal[400],
                                  size: 120,
                                ),
                              ),
                            ],
                          ), */
                          ),
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
