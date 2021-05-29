import 'package:flutter/material.dart';
import 'package:blood_share/Pages/prediction_chart.dart';

// Drop down menu in App Bar
// About page, Report page etc.
class AppBarDropDownMenu extends StatelessWidget {
  final Function showQRCode;
  final Function scanQRCode;
  final Function showAboutPage;
  final Function showReportPage;
  AppBarDropDownMenu({
    this.scanQRCode,
    this.showAboutPage,
    this.showQRCode,
    this.showReportPage,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          onChanged: (String selected) async {
            switch (selected) {
              case "Show":
                showQRCode();
                break;
              case "Scan":
                scanQRCode();
                break;
              case "Predict":
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Scaffold(
                          appBar: AppBar(
                            title: Text("Prediction"),
                          ),
                          body: MLPredictionTempPage());
                    },
                  ),
                );
                break;
              case "About":
                showAboutPage();
                break;
              case "Report":
                showReportPage();
                break;
            }
          },
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          items: [
            DropdownMenuItem(
              child: Center(
                child: Text(
                  "Prediction",
                  textAlign: TextAlign.center,
                ),
              ),
              value: "Predict",
            ),
            DropdownMenuItem(
              child: Center(
                child: Text(
                  "About",
                  textAlign: TextAlign.center,
                ),
              ),
              value: "About",
            ),
            DropdownMenuItem(
              child: Center(
                child: Text(
                  "Report",
                  textAlign: TextAlign.center,
                ),
              ),
              value: "Report",
            ),
          ],
        ),
      ),
    );
  }
}
