import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/authentication.dart';

/// delete account Page
///
/// delete password account or google sign in account
class DeletePasswordAccountForm extends StatefulWidget {
  @override
  _DeletePasswordAccountFormState createState() =>
      _DeletePasswordAccountFormState();
}

class DeleteGoogleAccountForm extends StatefulWidget {
  @override
  _DeleteGoogleAccountFormState createState() =>
      _DeleteGoogleAccountFormState();
}

class _DeletePasswordAccountFormState extends State<DeletePasswordAccountForm> {
  final _formKey = GlobalKey<FormState>();
  String _password, _email;
  bool _isLoading = false, _obsecure = true;

  Color _primaryColor;
  AuthService _authService;

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = context.read<User>().email;
    _authService = context.read<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return _isLoading
        ? CustomLoader("Deleting Account")
        : Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Delete My Account",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Enter your password to delete your Account\n$_email",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      obscureText: _obsecure,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String password) {
                        _password = password;
                      },
                      validator: (String password) {
                        password = password.trim();
                        if (password == null || password.isEmpty)
                          return "Enter Valid Password";
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: _obsecure
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obsecure = !_obsecure;
                            });
                          },
                        ),
                        hintText: "Password",
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: _onPressed,
                      child: Text(
                        "Delete Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      minWidth: double.infinity,
                      height: 50,
                      color: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  /// delete account
  void _onPressed() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // delete account
      String result = await _authService.deleteUserAccount(
        pass: _password,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.compareTo("Account Deleted") == 0) {
        // show account deleted dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Account Deleted",
              style: TextStyle(color: _primaryColor),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Account deleted for email\n$_email',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        Navigator.of(context).pop();
        // Navigator.of(context).pop();
        return;
      } else
        Scaffold.of(context).showSnackBar(
          // show error on snackbar
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: _primaryColor,
            elevation: 10,
            duration: Duration(seconds: 3),
            content: Text(
              result,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
    }
  }
}

class _DeleteGoogleAccountFormState extends State<DeleteGoogleAccountForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  bool _isLoading = false;
  Color _primaryColor;
  AuthService _authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = context.read<User>().email;
    _authService = context.read<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;

    return _isLoading
        ? CustomLoader("Deleting Account")
        : Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Delete My Account?",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Confirm your email",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (String email) {
                        _email = email;
                      },
                      validator: (String email) {
                        email = email.trim();
                        if (email.compareTo(_email) == 0) return null;
                        return "Enter valid Email";
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                        labelText: "Email",
                        fillColor: Colors.white,
                        suffixIcon: Icon(
                          Icons.email,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: _onPressed,
                      child: Text(
                        "Delete Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      minWidth: double.infinity,
                      height: 50,
                      color: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  /// delete account
  void _onPressed() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });
      // delete account
      String result = await _authService.deleteUserAccount(email: _email);

      setState(() {
        _isLoading = false;
      });

      if (result.compareTo("Account Deleted") == 0) {
        // show account deleted dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Account Deleted",
              style: TextStyle(color: _primaryColor),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Account deleted for email\n$_email',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        Navigator.of(context).pop();
        // Navigator.of(context).pop();
        return;
      } else
        Scaffold.of(context).showSnackBar(
          // show error on snackbar
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: _primaryColor,
            elevation: 10,
            duration: Duration(seconds: 3),
            content: Text(
              result,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
    }
  }
}
