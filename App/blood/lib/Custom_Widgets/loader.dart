import 'package:flutter/material.dart';

// custom circular progress indiacator
// with specific message
class CustomLoader extends StatelessWidget {
  final String _loadMsg;
  CustomLoader([this._loadMsg]);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.purpleAccent[400],
            ),
            backgroundColor: Colors.purpleAccent[100],
          ),
        ),
        SizedBox(
          height: _loadMsg != null ? 20 : null,
        ),
        _loadMsg != null
            ? Text(
                _loadMsg + "...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.purple[700],
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
