import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Auth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  FirebaseUser _firebaseUser;

  get user {
    return _firebaseUser;
  }

  get isNewUser {
    // return _authResult.additionalUserInfo.isNewUser;
    return this._firebaseUser.metadata.creationTime ==
        this._firebaseUser.metadata.lastSignInTime;
  }

  void setUser(FirebaseUser user) {
    this._firebaseUser = user;
  }

  Future<void> emailSignup(String email, String password) async {
    this._authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    this._firebaseUser = await FirebaseAuth.instance.currentUser();
  }

  Future<void> emailLogin(String email, String password) async {
    this._authResult = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    this._firebaseUser = await FirebaseAuth.instance.currentUser();
  }

  Future<void> checkUsername(String username) async {
    QuerySnapshot activeUsernamesSnapshot =
        await Firestore.instance.collection('userNames').getDocuments();

    List activeUsernamesDocuments = activeUsernamesSnapshot.documents;
    List activeUsernames = [];

    for (var i in activeUsernamesDocuments) {
      activeUsernames.add(i.documentID);
    }

    if (activeUsernames.contains(username)) {
      throw (PlatformException(
          message: "The username is already in use by another account.",
          code: "USERNAME_DUPLICATE"));
    }
  }

  Future<void> sendUsername(String username, String email) async {
    // create document for new user
    await Firestore.instance
        .collection('users')
        .document(this._authResult.user.uid)
        .setData({
      'username': username,
      'email': email,
    });

    // add username to userNames collection lsit
    await Firestore.instance
        .collection('userNames')
        .document(username)
        .setData({'id': _firebaseUser.uid});
  }

  Future<void> signout() async {
    try {
      _auth.signOut();
    } catch (a) {
      print('Sign Out Error');
    }
    this._firebaseUser = null;
  }
}
