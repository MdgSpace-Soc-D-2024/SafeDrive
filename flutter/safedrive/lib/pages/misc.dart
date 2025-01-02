import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

Future<double> getElevation(LatLng pos) async {
  final String elevationAPIKey = googleAPIKey;
  final String elevationUrl =
      'https://maps.googleapis.com/maps/api/elevation/json?locations=${Uri.encodeComponent(pos.latitude.toString())},${Uri.encodeComponent(pos.longitude.toString())}&key=$elevationAPIKey';

  try {
    // Send the GET request to the Google Elevation API
    final response = await http.get(Uri.parse(elevationUrl));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        // Return the elevation, in meters
        print("Elevation data found!$data");
        return data['results'][0]['elevation'];
      } else {
        print("No elevation data found");
        return 0.0;
      }
    } else {
      print("Status: $response.statusCode");
      return 1.0;
    }
  } catch (e) {
    print("Error: $e");
    return 2.0;
  }
}

double calculateSlopePercent(double rise, double run) {
  // print("Rise and Run");
  return (rise / run) * 100;
}

Location _locationController = new Location();
LatLng? userCurrentLocation;
// Function to get the current location once
Future<LatLng?> getCurrentLocationOnce() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await _locationController.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await _locationController.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }

  _permissionGranted = await _locationController.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await _locationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  LocationData currentLocation = await _locationController.getLocation();

  if (currentLocation.latitude != null && currentLocation.longitude != null) {
    userCurrentLocation =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    return userCurrentLocation;
  }
}

// Gets polyline points from google for the provided start and end coordinates
Future<List<LatLng>> getPolylinePointsFromCoordinates(
    LatLng startPoint, LatLng endPoint) async {
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: googleAPIKey,
    request: PolylineRequest(
      origin: PointLatLng(startPoint.latitude, startPoint.longitude),
      destination: PointLatLng(endPoint.latitude, endPoint.longitude),
      mode: TravelMode.driving,
    ),
  );
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  } else {
    print(result.errorMessage);
  }
  return polylineCoordinates;
}
