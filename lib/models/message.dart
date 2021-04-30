import 'package:flutter/material.dart';

class Message {
  final Key key;
  final String message;
  final String username;
  final bool isMe;

  Message({this.key, this.message, this.username, this.isMe});
}
