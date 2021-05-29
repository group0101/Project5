import 'package:blood_share/Forms/signup.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            // sign up form
            child: SingleChildScrollView(
              child: SignupForm(),
            ),
          ),
        ),
      ),
    );
  }
}
