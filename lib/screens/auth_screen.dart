import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  var _userName = '';

  void _trySubmit() async {
    final auth = Provider.of<Auth>(context, listen: false);
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      try {
        if (_isLogin) {
          await auth.emailLogin(
            _userEmail.trim(),
            _userPassword.trim(),
          );
        } else {
          await auth.checkUsername(_userName);
          await auth.emailSignup(
            _userEmail.trim(),
            _userPassword.trim(),
          );
          await auth.sendUsername(_userName, _userEmail);
        }
      } on PlatformException catch (err) {
        var message = 'An error occurred, please check your credentials!';

        if (err.message != null) {
          message = err.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;
    var _screenheight = _screenSize.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_screenheight * 0.04),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "The Græy Area",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'PT_Serif',
                      fontStyle: FontStyle.italic,
                      fontSize: _screenheight * 0.08,
                    ),
                  ),
                  SizedBox(
                    height: _screenheight * 0.025,
                  ),
                  Text(
                    _isLogin ? 'Log In' : 'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'PT_Serif',
                      fontWeight: FontWeight.bold,
                      fontSize: _screenheight * 0.025,
                    ),
                  ),
                  SizedBox(
                    height: _screenheight * 0.04,
                  ),
                  TextFormField(
                    style: TextStyle(color: Theme.of(context).accentColor),
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    key: ValueKey('email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  SizedBox(
                    height: _screenheight * 0.015,
                  ),
                  if (!_isLogin)
                    TextFormField(
                      style: TextStyle(color: Theme.of(context).accentColor),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      key: ValueKey('username'),
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  if (!_isLogin)
                    SizedBox(
                      height: _screenheight * 0.015,
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long';
                      }
                      return null;
                    },
                    style: TextStyle(color: Theme.of(context).accentColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  SizedBox(
                    height: _screenheight * 0.025,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      child: Icon(Icons.arrow_right),
                      onPressed: _trySubmit,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(color: Theme.of(context).accentColor)),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0))),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _screenheight * 0.025,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(_screenheight * 0.025),
                        ),
                      ),
                    ),
                    child: Text(
                        _isLogin
                            ? 'Create new account'
                            : 'I already have an account',
                        style: TextStyle(
                          fontFamily: 'PT_Serif',
                        )),
                    onPressed: () {
                      setState(
                        () {
                          _isLogin = !_isLogin;
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
