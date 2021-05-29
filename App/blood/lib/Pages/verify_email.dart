import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Services/authentication.dart';

// verify email page
class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  AuthService _authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = context.read<AuthService>();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
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
              child: Container(
                child: Text(
                  "Email Verification Link has been sent to\n${_authService.fireAuthInstace.currentUser.email}\nPlease click the link to verify\nyour email.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
