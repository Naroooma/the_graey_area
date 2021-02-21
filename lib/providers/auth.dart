import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class Auth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  AuthResult _authResult;

  get isNewUser {
    return _authResult.additionalUserInfo.isNewUser;
  }

  Future<void> emailSignup(String email, String password) async {
    this._authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // do something if user already exists
  }

  Future<void> emailLogin(String email, String password) async {
    this._authResult = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // do something if user doesn't exist
  }

  Future<void> sendUsername(String username, String email) async {
    await Firestore.instance
        .collection('users')
        .document(this._authResult.user.uid)
        .setData({
      'username': username,
      'email': email,
    });
  }

  Future<void> signout() async {
    try {
      _auth.signOut();
    } catch (e) {
      print('Sign Out Error');
    }
  }
}
