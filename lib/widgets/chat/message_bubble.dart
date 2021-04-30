import 'package:flutter/material.dart';
import 'package:the_graey_area/models/message.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
    this.m,
  );

  final Message m;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: m.key,
      children: [
        Row(
          mainAxisAlignment:
              m.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color:
                    m.isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                      !m.isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight:
                      m.isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              width: 140,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment:
                    m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    m.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: m.isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline1.color,
                    ),
                  ),
                  Text(
                    m.message,
                    style: TextStyle(
                      color: m.isMe
                          ? Colors.black
                          : Theme.of(context).accentTextTheme.headline1.color,
                    ),
                    textAlign: m.isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
