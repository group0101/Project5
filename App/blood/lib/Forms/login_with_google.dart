import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Services/authentication.dart';

/// Google sign in
class LoginWithGoogle extends StatelessWidget {
  final Function changeLoadingtate;
  LoginWithGoogle(this.changeLoadingtate);

  @override
  Widget build(BuildContext context) {
    AuthService _authService = Provider.of<AuthService>(context, listen: false);
    Color _splash = Theme.of(context).splashColor;

    return MaterialButton(
      shape: StadiumBorder(),
      height: 50,
      splashColor: _splash,
      color: Colors.white,
      elevation: 5,
      onPressed: () async {
        changeLoadingtate(true);
        // sign in with google
        await _authService.signInWithGoogle();
        changeLoadingtate(false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(" Login with Google"),
          SizedBox(
            width: 30,
          ),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/google.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
