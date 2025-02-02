import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:safedrive/pages/.env.dart';
import 'package:http/http.dart' as http;
// Google
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safedrive/pages/drive_screen.dart';

// Function to get user's current location at any time
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

// <----------------------------------- ELEVATION ------------------------------------------>
Future<List<double>> getElevations(List<LatLng> coordinates) async {
  final String elevationAPIKey = googleAPIKey;

  // Construct the locations string for the API (coordinates separated by |)
  String locations = coordinates
      .map((coord) =>
          '${Uri.encodeComponent(coord.latitude.toString())},${Uri.encodeComponent(coord.longitude.toString())}')
      .join('|'); // Coordinates separated by '|'

  final String elevationUrl =
      'https://maps.googleapis.com/maps/api/elevation/json?locations=$locations&key=$elevationAPIKey';

  try {
    // Send the GET request to the Google Elevation API
    final response = await http.get(Uri.parse(elevationUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        List<double> elevations = [];
        for (var result in data['results']) {
          if (result['elevation'] != null) {
            elevations.add(result['elevation']);
          } else {
            elevations.add(0.0);
          }
        }
        return elevations;
      } else {
        print("No elevation data found");
        return List.generate(coordinates.length, (_) => 0.0);
      }
    } else {
      print("Status: ${response.statusCode}");
      return List.generate(coordinates.length, (_) => 1.0);
    }
  } catch (e) {
    print("Error: $e");
    return List.generate(coordinates.length, (_) => 2.0);
  }
}

double calculateSlopePercent(double rise, double run) {
  // print("Rise and Run");
  return (rise / run) * 100;
}

// To be called only once
Map<LatLng, int> getStartPointsMap(List<List<LatLng>> pointsList) {
  Map<LatLng, int> startPointsMap = {};
  for (int i = 0; i < pointsList.length; i++) {
    LatLng target = pointsList[i][0];
    startPointsMap[target] = 0;
  }
  return startPointsMap;
}

List<LatLng> getStartPointsList(List<List<LatLng>> pointsList) {
  List<LatLng> startPointsList = [];
  for (int i = 0; i < pointsList.length; i++) {
    LatLng target = pointsList[i][0];
    startPointsList.add(target);
  }
  return startPointsList;
}

// <----------------------------------- SHARP TURNS ------------------------------------------>
class TurnDetector {
  // Function to calculate distance between two points (in meters)
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
        point1.latitude, point1.longitude, point2.latitude, point2.longitude);
  }

  // Function to calculate angle between three points A, B, C
  double calculateAngle(LatLng pointA, LatLng pointB, LatLng pointC) {
    double dx1 = pointA.latitude - pointB.latitude;
    double dy1 = pointA.longitude - pointB.longitude;
    double dx2 = pointC.latitude - pointB.latitude;
    double dy2 = pointC.longitude - pointB.longitude;

    double dotProduct = dx1 * dx2 + dy1 * dy2;

    double mag1 = sqrt(dx1 * dx1 + dy1 * dy1);
    double mag2 = sqrt(dx2 * dx2 + dy2 * dy2);

    double cosTheta = dotProduct / (mag1 * mag2);

    return acos(cosTheta) * (180 / pi);
  }

  bool isAngularTurn(
      LatLng point1, LatLng point2, LatLng point3, double threshold) {
    double angle = calculateAngle(point1, point2, point3);
    return angle < threshold;
  }

// The following function doesn't work as intended yet -- working on fixing it currently

  // Function to detect smooth sharp turns (Hairpin turns)
  bool isSmoothSharpTurn(
      List<LatLng> points, double distanceThreshold, double angleThreshold) {
    print(points);
    int smallDistanceCount = 0;
    // Tracking consecutive small distances
    double totalAngleChange = 0;
    // Tracking the total angle change between line segments

    for (int i = 0; i < points.length - 2; i++) {
      print("This loop has run $i times");
      double distance1 = calculateDistance(points[i], points[i + 1]);
      double distance2 = calculateDistance(points[i + 1], points[i + 2]);
      print("$distance1 $distance2 && $distanceThreshold");

      if (distance1 < distanceThreshold && distance2 < distanceThreshold) {
        // print("This is a smooth yet sharp turn : $points[i]");
        // Calculate the angle between the three points
        double angle = calculateAngle(points[i], points[i + 1], points[i + 2]);

        totalAngleChange += angle;
        // print(totalAngleChange);

        if (angle > angleThreshold) {
          // print("Angle is greater than the threshold!!!");
          smallDistanceCount++;
          print(smallDistanceCount);
        }
      }
    }

    // print(smallDistanceCount >= 2);
    print(totalAngleChange);
    // print(angleThreshold);
    print(smallDistanceCount >= 2);
    // print(totalAngleChange > angleThreshold);
    return smallDistanceCount >= 2 && totalAngleChange > angleThreshold;
  }

  List<List<LatLng>> detectTurns(List<LatLng> coordinates) {
    List<List<LatLng>> sharpTurnSegments = [];

    // Checking for angular turns
    for (int i = 0; i < coordinates.length - 2; i++) {
      bool isAngular = isAngularTurn(
          coordinates[i], coordinates[i + 1], coordinates[i + 2], 90);
      if (isAngular) {
        sharpTurnSegments
            .add([coordinates[i], coordinates[i + 1], coordinates[i + 2]]);
        // print(
        // "Angular sharp turn detected between points ${coordinates[i]}, ${coordinates[i + 1]}, ${coordinates[i + 2]}");
      }
    }

    //   // Checking for smooth sharp turns (hairpin turns)
    for (int i = 0; i < coordinates.length - 3; i++) {
      bool isSmoothSharp =
          isSmoothSharpTurn(coordinates.sublist(i, i + 4), 10, 0);
      print(isSmoothSharp);
      // Example thresholds: 10 meters for distance, 0 degrees for angle change
      if (isSmoothSharp) {
        sharpTurnSegments
            .add([coordinates[i], coordinates[i + 1], coordinates[i + 2]]);
        // print("Look here!");
        print(sharpTurnSegments);
        // print(
        // "Smooth sharp turn (hairpin turn) detected between points ${coordinates[i]}, ${coordinates[i + 1]}, ${coordinates[i + 2]}");
      }
    }

    //   // Return the list of sharp turn segments
    return sharpTurnSegments;
  }
}

// <----------------------------------- TRAFFIC DATA ------------------------------------------>
class TrafficService {
  final String googleApiKey = googleAPIKey;

  Future<Map<String, dynamic>> getTrafficData(
      LatLng origin, LatLng destination) async {
    double originLat = origin.latitude;
    double originLng = origin.longitude;
    double destinationLat = destination.latitude;
    double destinationLng = destination.longitude;
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$originLat%2C$originLng&destinations=$destinationLat%2C$destinationLng&departure_time=now&traffic_model=best_guess&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("TRAFFIC DATA FOLLOWS!!!");
      print(data);
      return data;
    } else {
      throw Exception("Failed to load traffic data");
    }
  }

  Future<String> getTrafficStatus(
      LatLng currentPosition, LatLng destination) async {
    var data = await getTrafficData(currentPosition, destination);
    int durationInTraffic =
        data['rows'][0]['elements'][0]['duration_in_traffic']['value'];
    int durationWithoutTraffic =
        data['rows'][0]['elements'][0]['duration']['value'];

    double percentageDifference =
        ((durationInTraffic - durationWithoutTraffic) /
                durationWithoutTraffic) *
            100;

    String trafficStatus;
    if (percentageDifference >= 30) {
      trafficStatus = "HIGH";
    } else if (percentageDifference >= 10) {
      trafficStatus = "NORMAL";
    } else {
      trafficStatus = "LOW";
    }

    return trafficStatus;
  }
}
