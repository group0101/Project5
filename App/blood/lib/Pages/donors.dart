import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_share/Pages/donor_datails.dart';
import 'package:blood_share/Custom_Widgets/loader.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Services/location_service.dart';

// nearby Donors list
class DonorsListView extends StatefulWidget {
  final String bloodGroup;
  DonorsListView({@required this.bloodGroup});
  @override
  _DonorsListViewState createState() => _DonorsListViewState();
}

class _DonorsListViewState extends State<DonorsListView> {
  LocationService _locationService;
  DataService _dataService;
  User _user;
  Future _future;
  // blood group compatibility
  Map<String, List<String>> _compatibles = {
    "O+": <String>["O+", "O-"],
    "O-": <String>["O-"],
    "A+": <String>["A+", "A-", "O+", "O-"],
    "A-": <String>["A-", "O-"],
    "B+": <String>["B+", "B-", "O+", "O-"],
    "B-": <String>["B-", "O-"],
    "AB-": <String>["AB-", "A-", "B-", "O-"]
  };

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    _user = context.read<User>();
    _dataService = DataService(uid: _user.uid);
    _locationService = context.read<LocationService>();
    _future = _dataService.getNearbyDonors();
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(
          title: Text("Donors"),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List donors = snapshot.data;
              // render all donors for AB+
              // else filter campatible donors
              if (widget.bloodGroup != "AB+")
                donors = donors.where(
                  (donor) {
                    return _compatibles[widget.bloodGroup]
                            .contains(donor["Blood Group"]) &&
                        donor["uid"] != _user.uid;
                  },
                ).toList();
              else
                donors = donors.where(
                  (donor) {
                    return donor["uid"] != _user.uid;
                  },
                ).toList();
              // render donor list with refresh indicator
              return RefreshIndicator(
                backgroundColor: _primaryColor,
                color: Colors.white,
                onRefresh: () async {
                  await _dataService.getNearbyDonors(refresh: true);
                  Future refreshed = _dataService.getNearbyDonors();
                  setState(() {
                    _future = refreshed;
                  });
                },
                child: donors.length > 0
                    ? ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: donors.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(
                              top: 8.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: ListTile(
                              isThreeLine: true,
                              dense: false,
                              contentPadding: EdgeInsets.all(8.0),
                              leading: donors[index]["photoURL"] != null &&
                                      donors[index]["photoURL"]
                                          .startsWith("http")
                                  ? Image.network(
                                      donors[index]["photoURL"],
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      "assets/user.jpg",
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.contain,
                                    ),
                              trailing: IconButton(
                                splashRadius: 24,
                                icon: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: _primaryColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      fullscreenDialog: true,
                                      maintainState: false,
                                      transitionDuration:
                                          Duration(milliseconds: 250),
                                      reverseTransitionDuration:
                                          Duration(milliseconds: 150),
                                      pageBuilder:
                                          (BuildContext context, animate, _) {
                                        return ScaleTransition(
                                          scale: animate,
                                          child: DonorInfoPage(donors[index]),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: "Email",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "\n${donors[index]["email"]}",
                                      style: TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  text: "Name",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "\n${donors[index]["displayName"]}",
                                      style: TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\nBlood Group : ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${donors[index]["Blood Group"]}",
                                      style: TextStyle(
                                        color: _primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : LocationService.hasLocationPermission
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/notfound.png",
                                  height: 78,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "No Matching Results Found",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Please Enable Location permission",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                RaisedButton.icon(
                                  label: Text("Enable"),
                                  icon: Icon(Icons.gps_fixed),
                                  onPressed: () {
                                    _enableLocation(context);
                                  },
                                ),
                              ],
                            ),
                          ),
              );
            }
            if (snapshot.hasError)
              return Center(
                child: Text(
                  "Error Occured\n\nPlease make sure that Location Permission\nis Granted.",
                  textAlign: TextAlign.center,
                ),
              );
            return CustomLoader("Searching Donaors");
          },
        ));
  }

  // enable location service if not enabled
  Future<bool> _enableLocation(BuildContext context) async {
    bool isCanceled;
    // enable location service
    String enableResult = await _locationService.enableLocationService();
    if (enableResult == "enabled") {
      return true;
    }

    // if denied forever then ask for opening location settings
    if (enableResult == "denied-forever")
      isCanceled = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Location Acceess Denied",
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Go to Location settings and enable\nLocation Access?",
              textAlign: TextAlign.center,
            ),
            actions: [
              FlatButton(
                child: Text("CANCEL"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text("SETTINGS"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      );
    if (isCanceled) return false;
    // open location permission settings to enable locatiopn permission
    await _locationService.openSettings();
    return false;
  }
}
