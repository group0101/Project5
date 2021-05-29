import 'package:flutter/material.dart';
import 'package:blood_share/Forms/forgot_password.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Reset"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            // password reset form
            child: PasswordResetForm(),
          ),
        ),
      ),
    );
  }
}
