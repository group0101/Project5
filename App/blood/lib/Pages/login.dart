import 'package:flutter/material.dart';
import 'package:blood_share/Forms/login.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: SingleChildScrollView(
              // login form
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}
