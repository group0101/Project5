import 'package:flutter/material.dart';
import 'package:blood_share/Custom_Widgets/app_logo_animation.dart';

/// About page
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    Color _primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: _size.height * 0.025,
          ),
          SizedBox(
            height: _size.height * 0.25,
            child: RiveAnimation(),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Blood",
              style: TextStyle(
                color: Color(0xFFFF0000),
                fontSize: _size.height * 0.035,
                fontFamily: "georgia",
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 1,
                    offset: Offset(1, 1),
                    color: Colors.black38,
                  ),
                ],
              ),
              children: [
                TextSpan(
                  text: " Share",
                  style: TextStyle(
                    color: Color(0xFF1DCA6B),
                    fontFamily: "georgia",
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 1,
                        offset: Offset(1, 1),
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _size.height * 0.04,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "“ ",
                  style: TextStyle(
                    color: Color(0xFFFF5555),
                    fontFamily: "georgia",
                    fontSize: _size.height * 0.024,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Donate blood and be a hero \nof someone’s life",
                  style: TextStyle(
                    fontFamily: "georgia",
                    fontStyle: FontStyle.italic,
                    color: _primary,
                    fontSize: _size.height * 0.018,
                  ),
                ),
                TextSpan(
                  text: " ”",
                  style: TextStyle(
                      color: Color(0xFFFF5555),
                      fontFamily: "georgia",
                      fontSize: _size.height * 0.024,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _size.height * 0.06,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlatButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text("About"),
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Blood Share",
                      applicationVersion: "1.0.0",
                      applicationIcon: SizedBox(
                        height: 36,
                        width: 36,
                        child: RiveAnimation(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: _size.height * 0.04,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
