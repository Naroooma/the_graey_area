import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final isLogin;

  AuthForm(this.submitFn, this.isLogin); // input paramater aren't put in state

  final void Function(
    String email,
    String password,
    String userName,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>(); // for form validation
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _isLogin,
        context,
      );
    } else {
      print('not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
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
                    fontSize: 75,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  _isLogin ? 'Log In' : 'Sign Up',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'PT_Serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 30,
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
                  height: 10,
                ),
                TextFormField(
                  style: TextStyle(color: Theme.of(context).accentColor),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  key: ValueKey('username'),
                  autocorrect: false,
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
                SizedBox(
                  height: 10,
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
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    child: Icon(Icons.arrow_right),
                    onPressed: _trySubmit,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).accentColor,
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
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
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
