import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/authentication.dart';
import 'package:blood_share/Forms/login_with_google.dart';

/// login form
///
/// login with email and password
///
/// or login with google sign in
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _obsecure = true, _isLoading = false;
  Color _primaryColor;
  AuthService _authService;

  @override
  void initState() {
    //  implement initState
    super.initState();
    _authService = context.read<AuthService>();
  }

  @override
  void setState(fn) {
    //  implement setState
    if (this.mounted) super.setState(fn);
  }

  /// toggle loading state and re-build
  void changeLoadingState(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return _isLoading
        ? CustomLoader("Signing in")
        : Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                        // regex pattern for email
                        String p = r"(\w+)@(\w+)[.](\w+)";
                        // create regular expression object
                        final regExp = RegExp(p);
                        // check is regex has match
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      obscureText: _obsecure,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String password) {
                        _password = password;
                      },
                      validator: (String password) {
                        password = password.trim();
                        if (password.isNotEmpty) return null;
                        return "Enter valid Password";
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
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: FlatButton(
                      onPressed: () {
                        //forgot password screen
                        Navigator.of(context).pushNamed("reset");
                      },
                      textColor: Colors.purple[700],
                      child: Text('Forgot Password'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: FlatButton(
                      onPressed: () {
                        _onPressed();
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      minWidth: double.infinity,
                      height: 50,
                      color: _primaryColor,
                      // shape: StadiumBorder(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Don't have an account?"),
                        FlatButton(
                          textColor: Colors.purple[700],
                          child: Text(
                            'Sign up',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed("signup");
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    // login with google button
                    child: LoginWithGoogle(changeLoadingState),
                  ),
                ],
              ),
            ),
          );
  }

  /// login user
  void _onPressed() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // login with email and password
      String signInResult = await _authService.signInUser(
        email: _email,
        pass: _password,
      );

      setState(() {
        _isLoading = false;
      });

      // if error show error on snackbar
      Scaffold.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryColor,
          elevation: 10,
          duration: Duration(seconds: 3),
          content: Text(
            signInResult,
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
