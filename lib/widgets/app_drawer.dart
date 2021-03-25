import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/categories.dart';

class AppDrawer extends StatelessWidget {
  final BuildContext ctx;

  AppDrawer(this.ctx);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: DrawerHeader(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text("Categories"),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.popUntil(context, ModalRoute.withName("/"));
                        Provider.of<Categories>(ctx, listen: false)
                            .reset(); // resets fav categories
                        Provider.of<Auth>(ctx, listen: false).signout();
                      },
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text("Log Out"),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
