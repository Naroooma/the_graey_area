import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/partner.dart';
import 'package:the_graey_area/screens/chat_screen.dart';
import 'package:the_graey_area/widgets/reqAutoText.dart';

class PartnerSearcher extends StatelessWidget {
  final qID;
  final answer;
  final lookingFor;

  PartnerSearcher(this.qID, this.answer, this.lookingFor);

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;

    var _screenheight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var _screenwidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: Provider.of<Partner>(context, listen: false)
          .searchForPartner(answer, lookingFor),
      builder: (ctx, snapshot) {
        return Consumer<Partner>(builder: (context, provider, child) {
          if (provider.chatID == 0) {
            return Column(children: [
              CircularProgressIndicator(),
              SizedBox(
                height: _screenheight * 0.07,
              ),
              ReqAutoText(
                  'No Match Found Yet', _screenSize, _screenheight * 0.06),
              SizedBox(
                height: _screenheight * 0.025,
              ),
              ReqAutoText('Meanwhile, answer more questions!', _screenSize,
                  _screenheight * 0.11)
            ]);
          } else if (provider.chatID != null) {
            return Column(
              children: [
                ReqAutoText('Match found, press button to chat!', _screenSize,
                    _screenheight * 0.12),
                SizedBox(
                  height: _screenheight * 0.06,
                ),
                ElevatedButton(
                    child: Container(
                      height: (_screenSize.height -
                              MediaQuery.of(context).padding.top) *
                          0.08,
                      width: _screenSize.width * 0.15,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                        size: _screenSize.width * 0.1,
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
