import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:vibration/vibration.dart';

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

// Function to check if marker is inside radius of target coordinates
void vibrateIfSteepSlope(
    LatLng marker, Map<LatLng, int> targetStatus, List<LatLng> targets) async {
  bool hasVibrator =
      await Vibration.hasVibrator() ?? false; // Handle nullable bool
  if (hasVibrator) {
    double radius = 10; // 10 meters
    for (int i = 0; i < targets.length; i++) {
      LatLng target = targets[i];

      // Check the distance first
      double distanceInMeters = Geolocator.distanceBetween(
          marker.latitude, marker.longitude, target.latitude, target.longitude);

      // If the marker is within the radius, check the target status
      if (distanceInMeters <= radius) {
        print("Marker entered the radius for target: $target");

        // Check if the target has not been entered (status = 0) and mark it as entered
        if (targetStatus[target] == 0) {
          Vibration.vibrate(duration: 1000); // Vibrate for 1 second

          targetStatus[target] = 1; // Mark this target as entered
        }
      }
    }
  }
}

// To be called only once
Map<LatLng, int> getStartPointsMap(List<List<LatLng>> steepSlopePoints) {
  Map<LatLng, int> startPointsMap = {};
  for (int i = 0; i < steepSlopePoints.length; i++) {
    LatLng target = steepSlopePoints[i][0];
    startPointsMap[target] = 0;
  }
  return startPointsMap;
} // Goes to isMarkerInsideRadius

List<LatLng> getStartPointsList(List<List<LatLng>> steepSlopePoints) {
  List<LatLng> startPointsList = [];
  for (int i = 0; i < steepSlopePoints.length; i++) {
    LatLng target = steepSlopePoints[i][0];
    startPointsList.add(target);
  }
  return startPointsList;
} // Goes to isMarkerInsideRadius
