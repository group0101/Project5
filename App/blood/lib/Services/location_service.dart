import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// fetch users current location
class LocationService extends ChangeNotifier {
  static bool hasLocationPermission = false;
  static Position myLocation;
  LocationService() {
    enableLocationService();
  }

  /// enable location service
  Future<String> enableLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    // check if location service is available
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'services-disabled';
    }

    // check if permission is available
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return 'denied-forever';
    }

    if (permission == LocationPermission.denied) {
      // request location permission
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return 'denied';
      }
    }
    hasLocationPermission = true;
    // get current location
    myLocation = await getCurrentLocation();
    // notify listener widgets about current location
    notifyListeners();
    return "enabled";
  }

  bool hasPermission() {
    return hasLocationPermission;
  }

  Future<Position> getCurrentLocation() async {
    myLocation = await Geolocator.getCurrentPosition();
    notifyListeners();
    return myLocation;
  }

  Future<CameraPosition> getCurrentLocationCameraPosition(
      {double zoom = 19}) async {
    // await getCurrentLocation();
    return CameraPosition(
      target: LatLng(myLocation.latitude, myLocation.longitude),
      zoom: zoom,
    );
  }

  /// enable real time location update
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      intervalDuration: Duration(milliseconds: 1500),
    );
  }

  /// open location settings
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  /// calculate distance between two location co-ordinates
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
