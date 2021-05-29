import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_share/Pages/map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// blood banks detail page
///
/// view details of blood bank when clicked
///
/// Name, Address, contact details, email etc.
class BloodBankPage extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;
  BloodBankPage(this.snapshot);

  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            bottom: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                child: Text(
                  snapshot["NAME"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (snapshot["ADDRESS"].toString().length > 5)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Address : ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${snapshot["ADDRESS"]}',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (snapshot["PINCODE"].toString().length > 5)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Pincode : ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${snapshot["PINCODE"]}',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (snapshot["HELPLINE"].toString().length > 5)
                Flexible(
                  child: CardField(
                    field: "Helpline",
                    value: snapshot["HELPLINE"],
                    icon: Icons.phone_enabled,
                  ),
                ),
              if (snapshot["MOBILE"].toString().length > 5)
                Flexible(
                  child: CardField(
                    field: "Contact",
                    value: snapshot["MOBILE"],
                    icon: Icons.phone_enabled,
                  ),
                ),
              if (snapshot["CONTACT"].toString().length > 5)
                Flexible(
                  child: CardField(
                    field: "Alternate Contact",
                    value: snapshot["CONTACT"],
                    icon: Icons.phone_enabled,
                  ),
                ),
              if (snapshot["EMAIL"].toString().length > 5)
                Flexible(
                  child: CardField(
                    field: "Email",
                    value: snapshot["EMAIL"],
                    icon: Icons.email,
                  ),
                ),
              if (snapshot["WEBSITE"].toString().trim().startsWith("http"))
                Flexible(
                  child: CardField(
                    field: "Website",
                    value: snapshot["WEBSITE"],
                    icon: Icons.launch,
                  ),
                ),
              FlatButton.icon(
                icon: Icon(
                  Icons.pin_drop,
                  color: Colors.white,
                ),
                color: _primary,
                shape: StadiumBorder(),
                label: Text(
                  "View on Map",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        // view blood bank location on map
                        return BloodBankLocationMapView(
                          snapshot: snapshot,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardField extends StatelessWidget {
  final String field;
  final value;
  final IconData icon;

  CardField({
    @required this.field,
    @required this.value,
    @required this.icon,
  });

  // launch email or dialer application
  Future<String> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return 'Could not launch $url';
    }
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    return InkWell(
      onLongPress: () {
        // create clipboard data object for value
        ClipboardData _cd = ClipboardData(text: value);
        // add data to clipboard
        Clipboard.setData(_cd);
        // show copied data message on snackbar
        Scaffold.of(context).showSnackBar(
          SnackBar(
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _primary,
            elevation: 5,
            duration: Duration(seconds: 1),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "\u{2713}",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.greenAccent,
                  ),
                ),
                Text(
                  "Copied to Clipboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: '$field :\n',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$value',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: "$field",
              splashRadius: 24,
              icon: Icon(icon),
              onPressed: () {
                // create launch url
                String url;
                switch (field) {
                  case "Website":
                    url = "$value";
                    break;
                  case "Email":
                    url = "mailto:$value";
                    break;
                  default:
                    url = "tel:$value";
                }
                List<String> urlList;

                // split if multiple details available
                if (url.contains(','))
                  urlList = url.contains(',') ? url.split(',') : null;
                if (urlList != null) url = urlList[0];

                // launch url in associated system app
                _launchURL(url).then(
                  (String result) {
                    if (result != "Success")
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _primary,
                          elevation: 5,
                          duration: Duration(seconds: 1),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\u{274C}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Failed to Launch $field",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
