import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/partner.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/widgets/reqAutoText.dart';

class PartnerSearcher extends StatelessWidget {
  var qID;
  var answer;
  var lookingFor;

  PartnerSearcher(this.qID, this.answer, this.lookingFor);

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: Provider.of<Partner>(context, listen: false)
          .searchForPartner(answer, lookingFor),
      builder: (ctx, snapshot) {
        return Consumer<Partner>(builder: (context, provider, child) {
          if (provider.chatID == 0) {
            return Column(children: [
              CircularProgressIndicator(),
              SizedBox(
                height: _screenSize.height / 15,
              ),
              ReqAutoText(
                  'No Match Found Yet', _screenSize, _screenSize.height / 17),
              SizedBox(
                height: _screenSize.height / 35,
              ),
              ReqAutoText('Meanwhile, answer more questions!', _screenSize,
                  _screenSize.height / 10)
            ]);
          } else if (provider.chatID != null) {
            return Column(
              children: [
                ReqAutoText('Match found, press button to chat!', _screenSize,
                    _screenSize.height / 9),
                SizedBox(
                  height: _screenSize.height / 20,
                ),
                ElevatedButton(
                    child: Container(
                      height: 70,
                      width: 70,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                        size: 40,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Theme.of(context).accentColor.withOpacity(0.7);
                        return Theme.of(context).accentColor;
                      }),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          ChatScreen.routeName,
                          arguments: [provider.qID, provider.chatID]);
                      provider.resetProvider();
                    })
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
      },
    );
  }
}
