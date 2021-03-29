import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerSearcher extends StatelessWidget {
  var qID;

  PartnerSearcher(this.qID);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, snapshot) {
        var userid = snapshot.data.uid;

        return StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(userid)
              .collection('active_questions')
              .document(qID)
              .snapshots(),
          builder: (ctx, snapshot) {
            var inWaitingRoom = snapshot.data['in_waiting_room'];
            if (inWaitingRoom) {
              return CircularProgressIndicator();
            } else {
              return Text("Found A Partner! go to chat section to talk");
            }
          },
        );
      },
    );
  }
}
