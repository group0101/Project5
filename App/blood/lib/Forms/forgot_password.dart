import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/authentication.dart';

/// forgot password page
///
/// confirm password or email to delete account
class PasswordResetForm extends StatefulWidget {
  @override
  _PasswordResetFormState createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  bool _isLoading = false;
  AuthService _authService;
  Color _primaryColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = context.read<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return _isLoading
        ? CustomLoader("Sending Link")
        : Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Forgot Password",
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
                    "Enter your Email, we will send you a link \nto reset your password",
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
                        // email regex pattern
                        String p = r"(\w+)@(\w+)[.](\w+)";
                        // regex object
                        final regExp = RegExp(p);
                        // check if regex pattern matches
                        if (regExp.hasMatch(email)) return null;
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
                        "Send Link",
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

  /// forgot password
  void _onPressed() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // send password reset link to email
      String result = await _authService.resetPassword(email: _email);
      setState(() {
        _isLoading = false;
      });

      if (result.compareTo("Link Sent") == 0) {
        // show result dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Link Sent",
              style: TextStyle(color: _primaryColor),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'password reset link has been sent to your email\n$_email',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Continue to Login?',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
        return;
      } else
        Scaffold.of(context).showSnackBar(
          // show error snackbar
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
              label: 'Ok',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
    }
  }
}
