import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:location/location.dart';
import 'mapscreen.dart';
import 'misc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';

class DriveScreen extends StatefulWidget {
  DriveScreen({super.key});

  final LatLng initialLocation = LatLng(37.4223, -122.0848);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  final LatLng _initialCameraPosition = LatLng(37.4223, -122.0848);
  // this should store the LatLng of the place where the user was last at before closing the app

  int flag = 0;

  LatLng originPoint = LatLng(23.6755568, 86.1604257);
  LatLng destinationPoint = LatLng(23.670, 86.0);
  Location _locationController = new Location();
  GoogleMapController? mapController;
  LatLng? _currentP = LatLng(24, 86);

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    _initializeMapRenderer();
    super.initState();
    getLocationUpdates();
  }

  // Checks if our platform is Android and uses that to improve performance
  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  // Called when the map is fully initialized
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateCamera(_initialCameraPosition);
  }

// Updates the camera to animate to a specific location when the app is initialized
  void _updateCamera(LatLng pos) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: widget.initialLocation,
        zoom: 15.0,
      ),
    ));
  }

  // Updates the camera to our current location as we move
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13.0,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Marker? _destination;
  LatLng? _destinationPoint;
  LatLng? startPoint;
  LatLng? endPoint;

  // Add marker
  void _addMarker(LatLng pos) async {
    setState(
      () {
        flag = 0; // This means we need to get steep slope data again
        _destination = Marker(
            markerId: const MarkerId("_destination"),
            infoWindow: const InfoWindow(title: "Destination"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos);

        _destinationPoint = LatLng(pos.latitude, pos.longitude);
      },
    );

    startPoint = await getCurrentLocationOnce();
    endPoint = pos;
    if (startPoint != null && endPoint != null) {
      List<LatLng> polylineCoordinates =
          await getPolylinePointsFromCoordinates(startPoint!, endPoint!);
      generateRedPolylinesFromSteepPoints(polylineCoordinates);
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Google Map
                _currentP == null
                    ? const Center(
                        child: Text(
                          "Loading...",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      )
                    : GoogleMap(
                        // Markers
                        markers: {
                          // if (_origin != null) _origin!,
                          if (_destination != null) _destination!,

                          // Live location marker
                          Marker(
                            markerId: MarkerId("_currentLocation"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: _currentP!,
                            infoWindow: InfoWindow(
                              title: "Current Location",
                            ),
                          ),
                        },
                        polylines: Set<Polyline>.of(polylines.values),
                        onLongPress: _addMarker,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: widget.initialLocation,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType
                            .normal, // Use normal map type for simplicity
                        zoomControlsEnabled:
                            true, // Disable zoom controls if not needed
                        compassEnabled: true, // Disable compass if not needed
                      ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 500,
            child: FloatingActionButton(
              onPressed: () {
                _destinationPoint != null
                    ? mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                          target: _destinationPoint!,
                          zoom: 14.5,
                        )),
                      )
                    : () {};
              },
              mini: true,
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(Icons.center_focus_strong),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 150,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        insetPadding: EdgeInsets.all(10),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          width: MediaQuery.of(context).size.width * 0.90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.90,
                                padding: EdgeInsets.all(10),
                                // decoration: BoxDecoration(
                                //   border: Border(color: Colors.black),
                                // ),
                                child: Text(
                                  "Favorites",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection("favoritesList")
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Text(
                                        "No favorited locations yet.");
                                  } else {
                                    return Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              snapshot.data!.docs.length - 1,
                                          itemBuilder: (context, index) {
                                            var doc =
                                                snapshot.data!.docs[index];
                                            return GestureDetector(
                                              onTap: () {
                                                _addMarker(LatLng(
                                                    doc["Latitude"],
                                                    doc["Longitude"]));
                                                mapController?.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                      target: LatLng(
                                                          doc["Latitude"],
                                                          doc["Longitude"]),
                                                      zoom: 15.0,
                                                    ),
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child: ListTile(
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      doc['Name'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Drive to
                                                        ElevatedButton.icon(
                                                          onPressed: () {},
                                                          icon: Icon(Icons
                                                              .directions_car),
                                                          label: Text("Drive"),
                                                        ),
                                                        SizedBox(width: 8),
                                                        // Delete button
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "favoritesList")
                                                                .doc(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id)
                                                                .delete();
                                                          },
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          label: Text("Delete"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              elevation: 3,
              mini: true,
              backgroundColor: const Color.fromARGB(255, 241, 48, 48),
              foregroundColor: Colors.white,
              child: Icon(Icons.favorite_border),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
          print(_currentP);
        });

        // Update route if destination is set
        if (_destinationPoint != null) {
          getPolylinePoints().then((coordinates) => {
                generatePolylineFromPoints(coordinates),
                generateBluePolylinesFromSharpTurns(coordinates),
              });
          if (flag == 0) {
            // I want to run this every time destination is changed or set for the first time
            LatLng recordStart = _currentP!;
            LatLng recordEnd = _destinationPoint!;
            flag = 1;

            getPolylinePointsFromCoordinates(recordStart, recordEnd)
                .then((polylineCoordinates) {
              return calculateSlope(polylineCoordinates);
            }).then((steepSlopePoints) {
              Map<LatLng, int> startPointsMap =
                  getStartPointsMap(steepSlopePoints);
              List<LatLng> startPointsList =
                  getStartPointsList(steepSlopePoints);

              return vibrateIfSteepSlope(
                  _currentP!, startPointsMap, startPointsList);
            });
          }
        }
      }
    });
  }

  // Gets polyline points from Google
  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPIKey,
      request: PolylineRequest(
        origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
        destination: PointLatLng(
            _destinationPoint!.latitude, _destinationPoint!.longitude),
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

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<List<List<LatLng>>> calculateSlope(List<LatLng> points) async {
    print(2);
    // Get the elevations for all points in a single call
    List<double> elevations = await getElevations(points);

    List<List<LatLng>> steepSlopePoints = [];

    for (int i = 0; i < points.length - 1; i++) {
      print(3);
      LatLng point1 = points[i];
      LatLng point2 = points[i + 1];

      // Get elevations from the previously fetched list
      double elevation1 = elevations[i];
      double elevation2 = elevations[i + 1];

      print("Elevation 1: $elevation1, Elevation 2: $elevation2");

      double rise = (elevation2 - elevation1).abs();
      double run = Geolocator.distanceBetween(
          point1.latitude, point1.longitude, point2.latitude, point2.longitude);

      double slopePercent = calculateSlopePercent(rise, run);

      // Check if the slope is steep (greater than 5%)
      if (slopePercent > 5) {
        steepSlopePoints.add([point1, point2]);
      }
    }

    return steepSlopePoints;
  }

  void generateRedPolylinesFromSteepPoints(
      List<LatLng> polylineCoordinates) async {
    print(1);
    List<List<LatLng>> steepSlopePoints =
        await calculateSlope(polylineCoordinates);

    for (var pointsPair in steepSlopePoints) {
      LatLng point1 = pointsPair[0];
      LatLng point2 = pointsPair[1];

      PolylineId id = PolylineId(
          "red_poly_${point1.latitude}_${point1.longitude}_${point2.latitude}_${point2.longitude}");

      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red.shade400,
        points: pointsPair,
        width: 5,
      );
      setState(() {
        polylines[id] = polyline;
      });
    }
  }

  void generateBluePolylinesFromSharpTurns(List<LatLng> polylineCoordinates) {
    print("Starting sharp turn polyline generation");

    // Detect sharp turns
    List<List<LatLng>> sharpTurnPoints =
        TurnDetector().detectTurns(polylineCoordinates);
    print(sharpTurnPoints);

    // Iterate through each segment of sharp turns
    for (List<LatLng> segment in sharpTurnPoints) {
      // Define a unique id for the polyline (using string directly for PolylineId)
      PolylineId id =
          PolylineId('sharp_turn_${sharpTurnPoints.indexOf(segment)}');

      // Create the polyline with the segment points
      Polyline bluePolyline = Polyline(
        polylineId: id,
        color: Colors.blue.shade400, // Blue color for the polyline
        points: segment,
        width: 5, // Polyline width
      );

      // Add the polyline to the state
      setState(() {
        polylines[id] = bluePolyline; // Make sure the polylines map exists
        print("Added blue polyline from sharp turn segment");
      });
    }
  }

  bool _isDialogMounted = false;
  // Function to check if marker is inside radius of target coordinates
  void vibrateIfSteepSlope(LatLng marker, Map<LatLng, int> targetStatus,
      List<LatLng> targets) async {
    bool hasVibrator =
        await Vibration.hasVibrator() ?? false; // Handle nullable bool
    if (hasVibrator) {
      double radius = 10; // 10 meters
      for (int i = 0; i < targets.length; i++) {
        LatLng target = targets[i];

        // Check the distance first
        double distanceInMeters = Geolocator.distanceBetween(marker.latitude,
            marker.longitude, target.latitude, target.longitude);

        // If the marker is within the radius, check the target status
        if (distanceInMeters <= radius) {
          print("Marker entered the radius for target: $target");

          // Check if the target has not been entered (status = 0) and mark it as entered
          if (targetStatus[target] == 0) {
            Vibration.vibrate(duration: 1000); // Vibrate for 1 second

            targetStatus[target] = 1;

            // showDialog(
            //   context: context,
            //   barrierDismissible: true,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: Text('Warning!'),
            //       content: Text('You are approaching a steep slope.'),
            //     );
            //   },
            // );

            // // Automatically dismiss the dialog after 4 seconds
            // Future.delayed(Duration(seconds: 4), () {
            //   Navigator.of(context).pop(); // Dismiss the dialog
            //   print('Dialog dismissed after 4 seconds');
            // });
          }
        }
      }
    }
  }
}
