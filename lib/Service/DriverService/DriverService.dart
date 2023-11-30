import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import '../../Model/Tokens.dart';
import '../APIConnection.dart';
import 'package:geolocator/geolocator.dart';

class DriverService{
  late APIConnection _conn;
  late Tokens _tokens;
  String searchClientURL="http://10.0.2.2:8069/api/v1/driver/search";
  DriverService(this._tokens)
  {
    _conn=APIConnection(_tokens);
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Response> postRequestToSearchForClient( LatLng pos) async {
    const JsonEncoder encoder = JsonEncoder();
    var data = {'driverLat':pos.latitude , 'driverLong': pos.longitude};
    print("post request driver lat lng:"+encoder.convert(data));
    Response res=await APIConnection(_tokens).postRequest(searchClientURL, encoder.convert(data));
    return res;
  }
  Future<LatLng> getCurrentDriverPosition() async {
    Position pos=await _determinePosition();
    print ("current driver lat:"+pos.latitude.toString()+",long:"+pos.longitude.toString());
    return LatLng(pos.latitude,pos.longitude);
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}