import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:blood_share/Forms/update_profile.dart';
import 'package:blood_share/Services/location_service.dart';

class UpdateProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Profile",
        ),
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
              child: UpdateProfileForm(),
            ),
          ),
        ),
      ),
    );
  }
}

// location update map view
class LocationUpdate extends StatefulWidget {
  final double lat, lon;
  LocationUpdate({this.lat, this.lon});
  @override
  _LocationUpdateState createState() => _LocationUpdateState();
}

class _LocationUpdateState extends State<LocationUpdate> {
  MapType _mapType = MapType.normal;
  LatLng _target, _marker;
  Color _primaryColor, _layer = Colors.black54;
  double _zoom, _offset = -100;

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) super.setState(fn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.lat != 0.1 && widget.lon != 0.1) {
      _zoom = 18;
      _target = LatLng(
        widget.lat,
        widget.lon,
      );
    } else if (LocationService.myLocation != null) {
      _zoom = 18;
      _target = LatLng(
        LocationService.myLocation.latitude,
        LocationService.myLocation.longitude,
      );
    } else {
      _zoom = 4;
      _target = LatLng(
        21.145,
        82.081,
      );
    }
    _marker = _target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _offset = 0;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _offset = -100;
        });
      });
    });
  }

  /// update location in database
  void _updateLocation() async {
    bool _update = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Location'),
          content: RichText(
            text: TextSpan(
              text: 'Update Your Default Location ?',
              style: TextStyle(
                color: _primaryColor,
              ),
              children: [
                TextSpan(
                  text:
                      '\n\nYour Default Location will be\n set to Location of',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' Red Marker.\n',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      'This will be helpful for\npeople around you to find a Donor.',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(false); //Will not exit the App
              },
            ),
            FlatButton(
              child: Text('CONFIRM'),
              onPressed: () {
                Navigator.of(context).pop(true); //Will exit the App
              },
            )
          ],
        );
      },
    );
    if (_update) Navigator.of(context).pop(_marker);
  }

  /// toggle map style
  void _changeStyle() async {
    setState(() {
      if (_mapType == MapType.normal) {
        _layer = Colors.green;
        _mapType = MapType.hybrid;
      } else {
        _layer = Colors.black54;
        _mapType = MapType.normal;
      }
    });
  }

  // render map for selecting new location
  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: false,
            myLocationEnabled: true,
            mapType: _mapType,
            initialCameraPosition: CameraPosition(
              zoom: _zoom,
              target: _target,
            ),
            onTap: (LatLng latlng) {
              setState(() {
                _marker = latlng;
              });
            },
            onLongPress: (LatLng latlng) {
              setState(() {
                _marker = latlng;
              });
            },
            markers: <Marker>{
              Marker(
                markerId: MarkerId("1"),
                anchor: const Offset(0.5, 1.0),
                position: _marker,
                draggable: true,
                onDragEnd: (LatLng latlng) {
                  setState(() {
                    _marker = latlng;
                  });
                },
              ),
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              transform: Matrix4.translationValues(0, _offset, 0),
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Drop the ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "Red Marker ",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(
                        text: "to the\nDesired Location on Map",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton.extended(
                tooltip: "Set My Location",
                onPressed: _updateLocation,
                icon: Icon(
                  Icons.gps_fixed,
                ),
                label: Text("Update Location"),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 30.0),
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                tooltip: "Map Style",
                elevation: 10,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: _changeStyle,
                child: Icon(
                  Icons.layers,
                  color: _layer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
