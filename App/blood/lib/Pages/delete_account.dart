import 'package:flutter/material.dart';
import 'package:blood_share/Forms/delete_account.dart';

class DeletePasswordAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Account"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.transparent,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              // delete account form
              child: DeletePasswordAccountForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteGoogleSigninAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Account"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.transparent,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              child: DeleteGoogleAccountForm(),
            ),
          ),
        ),
      ),
    );
  }
}
