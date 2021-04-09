import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:the_graey_area/providers/partner.dart';

class PartnerSearcher extends StatelessWidget {
  var qID;
  var answer;
  var lookingFor;

  PartnerSearcher(this.qID, this.answer, this.lookingFor);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Partner>(context, listen: false)
          .searchForPartner(answer, lookingFor),
      builder: (ctx, snapshot) {
        return CircularProgressIndicator();
      },
    );
  }
}
