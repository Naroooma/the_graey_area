import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerSearcher extends StatelessWidget {
  var qID;
  var answer;
  var looking_for;

  PartnerSearcher(this.qID, this.answer, this.looking_for);

  Future<bool> searchForPartner(String userid) async {
    bool found = false;
    // look once to see if there is someone who matches conditions
    QuerySnapshot waitersSnapshot = await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .getDocuments();

    for (var i in waitersSnapshot.documents) {
      // if match, create chat
      if (i.documentID != userid &&
          i['answer'] == looking_for &&
          i['looking_for'] == answer) {
        await createChat(userid, i.documentID);
        return true;
      }
    }

    // if no match found, setup stream listner that waits for flag
    StreamSubscription foundListener;
    Stream<DocumentSnapshot> waitingSnapshot = Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(userid)
        .snapshots();

    foundListener = waitingSnapshot.listen((document) async {
      // when flaged, delete my waiting_room + stop stream
      String flag = document.data['chat'];
      print(flag);
      if (flag != null) {
        print("Chat Found At:");
        print(document.data['chat']);

        // stop stream
        foundListener.cancel();

        // delete personal waiting room entry
        await Firestore.instance
            .collection('questions')
            .document(qID)
            .collection('waiting_room')
            .document(userid)
            .delete();

        return true;
      }
    });
  }

  Future<void> createChat(userID, partnerID) async {
    // delete waiting room entry
    await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(userID)
        .delete();

    // create a chat document
    DocumentReference chatDoc = await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('chats')
        .add({'user1_id': userID, 'user2_id': partnerID});

    // notify partner i found him
    await Firestore.instance
        .collection('questions')
        .document(qID)
        .collection('waiting_room')
        .document(partnerID)
        .updateData({'chat': chatDoc.documentID});
  }

  @override
  Widget build(BuildContext context) {
    bool found = false;
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          var userid = snapshot.data.uid;

          return FutureBuilder(
              future: searchForPartner(userid),
              builder: (ctx, snapshot) {
                print(snapshot);
                print(snapshot.data);
                if (snapshot.data == true) {
                  return Text('Partner Found!!');
                } else {
                  return CircularProgressIndicator();
                }
              });
          // if (found) {
          //   return Text('A Partner for you has been');
          // } else {
          //   return StreamBuilder(
          //       stream: Firestore.instance
          //           .collection('questions')
          //           .document(qID)
          //           .collection('waiting_room')
          //           .snapshots(),
          //       builder: (ctx, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.waiting) {
          //           return CircularProgressIndicator();
          //         } else {
          //           var waitingUsers = snapshot.data.documents;

          //           if (waitingUsers != null) {
          //             for (var i in waitingUsers) {
          //               // if partner found you, or you found partner
          //               if ((i.documentID == userid &&
          //                       i['partner_found'] == true) ||
          //                   (i.documentID != userid &&
          //                       i['answer'] == looking_for)) {
          //                 // stop search
          //                 found = true;
          //                 // delete waiting room entry + notify partner that he was found + create chat entry
          //                 return FutureBuilder(
          //                   future: createChat(userid, i.documentID),
          //                   builder: (ctx, snapshot) {
          //                     return Container();
          //                   },
          //                 );
          //               }
          //             }
          //           }
          //           return Text('');
          //         }
          //       });
          // }

          // return StreamBuilder(
          //   stream: Firestore.instance
          //       .collection('users')
          //       .document(userid)
          //       .collection('active_questions')
          //       .document(qID)
          //       .snapshots(),
          //   builder: (ctx, snapshot) {
          //     var inWaitingRoom = snapshot.data['in_waiting_room'];
          //     if (inWaitingRoom) {
          //       return CircularProgressIndicator();
          //     } else {
          //       return Text("Found A Partner! go to chat section to talk");
          //     }
          //   },
          // );
        }
      },
    );
  }
}
