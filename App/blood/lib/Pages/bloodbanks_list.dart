import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blood_share/Pages/bloodbank_details.dart';
import 'package:blood_share/Services/location_service.dart';

/// show blood banks for selected criteria
class BloodBanksListPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> queryResult;

  // render blood bank list for given query result
  BloodBanksListPage(this.queryResult);

  @override
  _BloodBanksListPageState createState() => _BloodBanksListPageState();
}

class _BloodBanksListPageState extends State<BloodBanksListPage> {
  LocationService _locationService;
  @override
  Widget build(BuildContext context) {
    Color _primary = Theme.of(context).primaryColor;
    _locationService = context.watch<LocationService>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Banks"),
      ),
      body: widget.queryResult.isNotEmpty
          ? ListView.separated(
              shrinkWrap: true,
              itemCount: widget.queryResult.length,
              separatorBuilder: (_, int index) => Divider(
                color: _primary,
                height: 0,
                thickness: 1,
              ),
              itemBuilder: (_, int index) {
                return ListTile(
                  onTap: null,
                  contentPadding: const EdgeInsets.all(8.0),
                  trailing: IconButton(
                    splashRadius: 24,
                    icon: Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: _primary,
                    ),
                    onPressed: () {
                      // render list of blood banks
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          fullscreenDialog: true,
                          maintainState: false,
                          transitionDuration: Duration(milliseconds: 250),
                          reverseTransitionDuration:
                              Duration(milliseconds: 150),
                          pageBuilder: (BuildContext context, animate, _) {
                            return ScaleTransition(
                              scale: animate,
                              child: BloodBankPage(widget.queryResult[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  key: Key(widget.queryResult[index].data()["NAME"]),
                  title: Text(
                    widget.queryResult[index].data()["NAME"],
                    style: TextStyle(
                      color: Colors.purpleAccent,
                    ),
                  ),
                  subtitle: Text(
                    '\nAddress : ${widget.queryResult[index].data()["ADDRESS"]}\n',
                    style: TextStyle(color: _primary),
                  ),
                  isThreeLine: true,
                );
              },
            )
          : LocationService.hasLocationPermission
              ? Center(
                  // render if no matching results
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
                    // ask for location permission if needed
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

  // enable location service if not enabled
  Future<bool> _enableLocation(BuildContext context) async {
    bool isCanceled;
    // enable location service
    String enableResult = await _locationService.enableLocationService();
    if (enableResult == "enabled") {
      return true;
    }
    if (enableResult == "denied-forever")
      isCanceled = await showDialog(
        context: context,
        builder: (context) {
          // ask for location permission if user allows
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
    // open location settings if permission is permenantly denied
    await _locationService.openSettings();
    return false;
  }
}
