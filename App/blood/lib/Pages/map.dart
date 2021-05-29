import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_share/Services/data_service.dart';
import 'package:blood_share/Services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// map page
class MapView extends StatefulWidget {
  final double lattitude, longitude, zoom;
  // default center of map
  MapView({
    this.lattitude = 21.145,
    this.longitude = 82.081,
    this.zoom = 4,
  });
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  MapType _mapType = MapType.normal;
  bool _myLocationEnabled = false;
  LocationService _locationService;
  DataService _dataService;
  Set<Marker> _markers, _markerSet = {};
  CameraPosition _initialPosition;
  void initState() {
    // TODO: implement initState
    super.initState();
    _dataService = DataService();
    _locationService = context.read<LocationService>();
    _controller.future.then((GoogleMapController gmc) {
      // set map controller
      controller = gmc;
      // go to my location
      _goToMyLocation();
    });
    // set initial camera position
    _initialPosition = CameraPosition(
      target: LatLng(widget.lattitude, widget.longitude),
      zoom: widget.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (LocationService.hasLocationPermission) _setMarkers();
    return Stack(
      children: [
        GoogleMap(
          mapType: _mapType,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: false,
          myLocationEnabled: _myLocationEnabled,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 5.0, top: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  tooltip: "Map Style",
                  elevation: 5,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  onPressed: _changeStyle,
                  child: Icon(
                    Icons.layers,
                    color: Colors.black54,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  tooltip: "Mark Bloodbanks",
                  elevation: 5,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  onPressed: () async {
                    if (!_locationService.hasPermission()) {
                      _enableLocation(context);
                      return;
                    }
                    if (_markerSet == null) {
                      await _setMarkers();
                    }
                    if (_markers != null) {
                      return setState(() {
                        _markers = null;
                      });
                    }
                    setState(() {
                      _markers = _markerSet;
                    });
                    CameraPosition cameraPosition = await _locationService
                        .getCurrentLocationCameraPosition(zoom: 8);

                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition),
                    );
                  },
                  child: Icon(
                    Icons.location_on,
                    color: _markers == null ? Colors.black54 : Colors.blue,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  tooltip: "My Location",
                  elevation: 5,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  onPressed: () {
                    if (!_locationService.hasPermission()) {
                      _enableLocation(context);
                      return;
                    }
                    setState(() {
                      _myLocationEnabled = !_myLocationEnabled;
                    });
                    if (_myLocationEnabled) _goToMyLocation();
                  },
                  child: Icon(
                    Icons.gps_fixed,
                    color: _myLocationEnabled ? Colors.blue : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// animate camera view to my location
  Future<void> _goToMyLocation() async {
    CameraPosition cameraPosition =
        await _locationService.getCurrentLocationCameraPosition();
    Future.delayed(Duration(seconds: 1), () {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    });
  }

  // change map style
  void _changeStyle() async {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  // set markers for nearby blood banks
  Future<void> _setMarkers() async {
    List<QueryDocumentSnapshot> bloodBankDocumentsList =
        await _dataService.getNearbyBloodbanks();
    if (bloodBankDocumentsList != null) {
      _markerSet = bloodBankDocumentsList.map((bloodbankDocument) {
        return Marker(
          markerId: MarkerId(bloodbankDocument.data()["ID"].toString()),
          anchor: const Offset(0.5, 1.0),
          position: LatLng(
            bloodbankDocument.data()["LATITUDE"],
            bloodbankDocument.data()["LONGITUDE"],
          ),
          infoWindow: InfoWindow(
            title: '${bloodbankDocument.data()["NAME"]}',
            snippet: '${bloodbankDocument.data()["ADDRESS"]}}',
          ),
        );
      }).toSet();
    }
  }

  // enable location if not enabled
  Future<bool> _enableLocation(BuildContext context) async {
    bool isCanceled;
    // request permission
    String enableResult = await _locationService.enableLocationService();
    if (enableResult == "enabled") {
      return true;
    }
    // open settings to enable permission
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
    // open settings
    await _locationService.openSettings();
    return false;
  }
}

// view blood bank location on map
class BloodBankLocationMapView extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  BloodBankLocationMapView({@required this.snapshot});
  @override
  _BloodBankLocationMapViewState createState() =>
      _BloodBankLocationMapViewState();
}

class _BloodBankLocationMapViewState extends State<BloodBankLocationMapView> {
  MapType _mapType = MapType.normal;
  Color _layer = Colors.black54;

  // toggle map style
  // satellite or normal
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BloodBank Location"),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              myLocationButtonEnabled: false,
              compassEnabled: true,
              rotateGesturesEnabled: false,
              myLocationEnabled: false,
              mapType: _mapType,
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: LatLng(
                  widget.snapshot["LATITUDE"],
                  widget.snapshot["LONGITUDE"],
                ),
              ),
              markers: <Marker>{
                Marker(
                  markerId: MarkerId("marker"),
                  anchor: const Offset(0.5, 1.0),
                  position: LatLng(
                    widget.snapshot["LATITUDE"],
                    widget.snapshot["LONGITUDE"],
                  ),
                  infoWindow: InfoWindow(
                    title: '${widget.snapshot["NAME"]}',
                    snippet: '${widget.snapshot["ADDRESS"]}}',
                  ),
                ),
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 100.0),
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                tooltip: "Map Style",
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: _changeStyle,
                child: Icon(
                  Icons.layers,
                  color: _layer,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
