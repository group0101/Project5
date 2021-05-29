import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/authentication.dart';

///Sign up form
///
///enter email, password, and date of birth
///
///create user account if older than 18
class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  String _email, _passwordPrimary = "", _passwordConfirm = "", _dateString;
  DateTime _dateOfBirth;
  bool _obsecure = true,
      _obsecure1 = true,
      _isAgeValid = false,
      _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;

    return _isLoading
        ? CustomLoader("Signing up")
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
                        // check is regex has match
                        final regExp = RegExp(p);
                        // create regular expression object
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
                    child: TextFormField(
                      obscureText: _obsecure,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String password) {
                        _passwordPrimary = password;
                      },
                      validator: (String password) {
                        password = password.trim();
                        _passwordPrimary = password;
                        // regex pattern for password
                        String p =
                            r"^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$";
                        // create regular expression object
                        final regExp = RegExp(p);
                        // check is regex has match
                        if (regExp.hasMatch(password)) return null;
                        if (password.length < 8)
                          return "Password must be at least 8 characters";
                        return "Password must contain Number & Special character";
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
                    child: TextFormField(
                      obscureText: _obsecure1,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String password) {
                        _passwordConfirm = password;
                      },
                      validator: (String password) {
                        password = password.trim();
                        if (password.isNotEmpty &&
                            password.compareTo(_passwordPrimary) == 0)
                          return null;
                        if (password.isEmpty) return "Please confirm password";
                        return "Passwords didn't match";
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: _obsecure1
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obsecure1 = !_obsecure1;
                            });
                          },
                        ),
                        hintText: "Confirm Password",
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      // get current time
                      DateTime now = DateTime.now();
                      // show datepicker
                      DateTime selected = await showDatePicker(
                        context: context,
                        helpText: "PICK DATE OF BIRTH",
                        confirmText: "SELECT",
                        initialDate: now,
                        firstDate: DateTime(1900),
                        lastDate: now,
                      );
                      if (selected != null) {
                        // check if older than 18 years or not
                        _isAgeValid = now.year - selected.year < 18
                            ? false
                            : now.year - selected.year == 18
                                ? now.month < selected.month
                                    ? false
                                    : now.month == selected.month
                                        ? now.day < selected.day
                                            ? false
                                            : true
                                        : true
                                : true;
                        _dateString =
                            '${selected.day} / ${selected.month} / ${selected.year}';
                        setState(() {
                          _dateOfBirth = selected;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: _dateOfBirth != null
                            ? _isAgeValid
                                ? Border.all(color: Colors.black38)
                                : Border.all(color: Colors.red)
                            : Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateOfBirth != null
                                ? _isAgeValid
                                    ? _dateString
                                    : "You must be 18 or older"
                                : "Date of Birth",
                            style: _dateOfBirth != null
                                ? _isAgeValid
                                    ? TextStyle(
                                        color: Colors.black, fontSize: 16)
                                    : TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      )
                                : TextStyle(
                                    color: Colors.black54, fontSize: 16),
                          ),
                          Icon(Icons.calendar_today, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: FlatButton(
                      onPressed: _onPressed,
                      child: Text(
                        "Sign up",
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

  /// sign up with email and password
  void _onPressed() async {
    // validate form data
    bool valid = _formKey.currentState.validate();
    if (_isAgeValid && valid) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();

      bool confirmed = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Email Verification'),
            content: Text(
              'is this your email?\n\n$_email\n\nmake sure you have entered\ncorrect email',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('VERIFY'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        },
      );
      if (confirmed) {
        setState(() {
          _isLoading = true;
        });

        String createResult;

        // create account
        createResult = await _authService.createUser(
          email: _email,
          pass: _passwordConfirm,
        );

        setState(() {
          _isLoading = false;
        });

        // continue to login
        if (createResult.compareTo("User created") == 0) {
          Navigator.of(context).pop();
          return;
        } else
          Scaffold.of(context).showSnackBar(
            // show error on snackbar
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: _primaryColor,
              elevation: 5,
              duration: Duration(seconds: 3),
              content: Text(
                createResult,
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
}
