import 'package:flutter/material.dart';
import 'dart:async';
import 'package:safedrive/services/services.dart';
import '../models/misc.dart';
import 'setting_screen.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:safedrive/pages/offline_map_page.dart';
// Google
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
// Vibration and Sound
import 'package:vibration/vibration.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:just_audio/just_audio.dart';
// Connectivity
// import 'package:connectivity_plus/connectivity_plus.dart';

int speedInKmPerHour = 0;
LatLng initialLocation = LatLng(37.4223, -122.0848);
LatLng? lastLocation;
late Future<void> completed;

List<LatLng> latlngList = [];

// markers and destinations
Marker? _destination; // To store the destination marker
LatLng? _destinationPoint; // To store the marker's location
LatLng? startPoint; // Starting point of the drive
LatLng? endPoint; // Destination point of the drive

class DriveScreen extends StatefulWidget {
  const DriveScreen({super.key});

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  // create an instance of connectivity service
  // final _connectivityService = ConnectivityService();

  // initial camera position should be taken from shared preferences, but if it isn't present then we can use this value
  Future<void> getInitialLocations() async {
    initialLocation = await loadLastLocation();
  }

  int flag = 0;

  LatLng originPoint = LatLng(23.6755568, 86.1604257);
  LatLng destinationPoint = LatLng(23.670, 86.0);
  Location _locationController = new Location();
  GoogleMapController? mapController;
  LatLng? _currentP = LatLng(24, 86);

  String trafficStatus = '';

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    // initialize map renderer
    _initializeMapRenderer();

    // get the initial camera position of the user
    getInitialLocations();

    // initialize the parent classes
    super.initState();

    // get location updates of the user
    getLocationUpdates();

    // start downloading tiles for offline use
    completed = downloadTilesForOfflineUse();
  }

  // checks if our platform is Android and uses that to improve performance
  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  // called when the map is fully initialized
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateCamera(initialLocation);
  }

// updates the camera to animate to a specific location when the app is initialized
  void _updateCamera(LatLng pos) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: initialLocation,
        zoom: 15.0,
      ),
    ));
  }

  // updates the camera to our current location as we move
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

  // add marker
  void _addMarker(LatLng pos) async {
    setState(
      () {
        // to know if we need to get the steep slope data again, because destination has been reset
        flag = 0;
        // destination marker
        _destination = Marker(
            markerId: const MarkerId("_destination"),
            infoWindow: const InfoWindow(title: "Destination"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos);

        _destinationPoint = LatLng(pos.latitude, pos.longitude);
      },
    );

    // function to get the steep slope every time destination is reset

    // current location
    startPoint = await getCurrentLocationOnce();
    // destination marker
    endPoint = pos;

    if (startPoint != null && endPoint != null) {
      List<LatLng> polylineCoordinates =
          await getPolylinePointsFromCoordinates(startPoint!, endPoint!);
      trafficStatus = await TrafficService()
          .getTrafficStatus(startPoint!, polylineCoordinates[1]);

      if (preferences[2][1]) {
        generateRedPolylinesFromSteepPoints(polylineCoordinates);

        List<List<LatLng>> sharpTurnPoints =
            TurnDetector().detectTurns(polylineCoordinates);

        Map<LatLng, int> startPointsMap = getStartPointsMap(sharpTurnPoints);
        List<LatLng> startPointsList = getStartPointsList(sharpTurnPoints);
        playSoundIfInRadius(startPoint!, startPointsMap, startPointsList, 1);
      }
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

// <--------------------- WIDGETS START ------------------------>

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
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
                          // Destination marker
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
                          target: initialLocation,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType
                            .normal, // Use normal map type for simplicity
                        zoomControlsEnabled: true,
                        compassEnabled: true,
                      ),
              ],
            ),
            Positioned(
              right: 8,
              top: 60,
              // Button to move the camera to the destination on being pressed
              child: FloatingActionButton(
                onPressed: () {
                  _destinationPoint != null
                      ? mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                            target: _destinationPoint!,
                            zoom: 14.5,
                          )),
                        )
                      : () {
                          // Do nothing
                        };
                },
                mini: true,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Icons.center_focus_strong),
              ),
            ),
            Positioned(
              right: 8,
              top: 110,
              // button to display info on how to use the app
              child: FloatingActionButton(
                onPressed: () {
                  showInfoDialog(context);
                },
                mini: true,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Icons.question_mark_sharp),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 100,
              child: FloatingActionButton(
                // Favorites button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed: () {
                  // Shows a dialog with all the favorited locations on being pressed
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
                                                          onPressed: () {
                                                            _addMarker(LatLng(
                                                                doc["Latitude"],
                                                                doc["Longitude"]));
                                                          },
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
                    },
                  );
                },
                elevation: 3,
                mini: true,
                backgroundColor: const Color.fromARGB(255, 241, 48, 48),
                foregroundColor: Colors.white,
                child: Icon(Icons.favorite_border),
              ),
            ),
            // Speed display widget
            if (preferences[0][1])
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${speedInKmPerHour.toStringAsFixed(1)} km/h",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 10,
              right: 60,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: trafficStatus == "HIGH"
                      ? Colors.red.withAlpha(200)
                      : trafficStatus == "NORMAL"
                          ? Colors.yellow.withAlpha(200)
                          : trafficStatus == "LOW"
                              ? Colors.green.withAlpha(200)
                              : Colors.grey.withAlpha(200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "TRAFFIC :",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_destination != null)
                      Text(
                        trafficStatus,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// <-------------------- WIDGETS END ---------------------->

// <-------------------------- ROUTE GENERATION ------------------------------>

  // Store last location in shared preferences
  Future<void> _storeLastLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    lastLocation = LatLng(latitude, longitude);
    prefs.setDouble("lastLatitude", latitude);
    prefs.setDouble('lastLongitude', longitude);
  }

  // Gets real time location updates at fixed intervals
  Future<void> getLocationUpdates() async {
    bool _serviceEnabled; // Checks if location service is enabled
    PermissionStatus
        _permissionGranted; // Checks if permission to get user's live location has been granted

    // For location service
    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    // For location permissions
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    //  Listener to check when the user's current location changes
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          // Speed
          if (currentLocation.speed != null) {
            double speedInMetersPerSecond = currentLocation.speed!;
            // ignore: unused_local_variable
            double speedInKmPerHour = speedInMetersPerSecond * 3.6;
            // double speedInMilesPerHour = speedInKmPerHour / 1.689;
          }
          // Current Position
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
          // print(_currentP);

          // Store the current location as last location
          _storeLastLocation(
              currentLocation.latitude!, currentLocation.longitude!);
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

            // Getting coordinates of the path -> Getting elevation of all the points on the path -> Checking if the elevation difference between any two points is more than normal
            // -> Displaying a red line between those coordinates -> Making the device vibrate when the user's current location is in a certain radius of the starting point of those steep elevations

            getPolylinePointsFromCoordinates(recordStart, recordEnd)
                .then((polylineCoordinates) {
              return calculateSlope(polylineCoordinates);
            }).then((steepSlopePoints) {
              if (preferences[2][1]) {
                Map<LatLng, int> startPointsMap =
                    getStartPointsMap(steepSlopePoints);

                List<LatLng> startPointsList =
                    getStartPointsList(steepSlopePoints);

                return playSoundIfInRadius(
                    _currentP!, startPointsMap, startPointsList, 0);
              }
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

  // Generates polylines based on data from Google Directions API
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

// <-------------------------------- ELEVATION ----------------------------------->

  // Gets elevations for all points on the path
  Future<List<List<LatLng>>> calculateSlope(List<LatLng> points) async {
    // List to store the lists of steep points (their starting and ending coordinates)
    List<List<LatLng>> steepSlopePoints = [];

    if (preferences[2][1]) {
      // print(2); // For debugging

      // Get the elevations for all points in a single call so as to not make uneccessary requests + its faster
      List<double> elevations = await getElevations(points);

      for (int i = 0; i < points.length - 1; i++) {
        // print(3); // For debugging
        LatLng point1 = points[i];
        LatLng point2 = points[i + 1];

        // Get elevations from the previously fetched list
        double elevation1 = elevations[i];
        double elevation2 = elevations[i + 1];

        // print("Elevation 1: $elevation1, Elevation 2: $elevation2");

        double rise = (elevation2 - elevation1).abs();
        double run = Geolocator.distanceBetween(point1.latitude,
            point1.longitude, point2.latitude, point2.longitude);

        double slopePercent = calculateSlopePercent(rise, run);

        // Check if the slope is steep (greater than 5%)
        if (slopePercent > 5) {
          steepSlopePoints.add([point1, point2]);
        }
      }
    }
    return steepSlopePoints;
  }

  // Generates red lines on the Google Map wherever the elevation is steeper than 5%
  void generateRedPolylinesFromSteepPoints(
      List<LatLng> polylineCoordinates) async {
    if (preferences[2][1]) {
      // print(1); // For debugging
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
  }

  // Function to show overlay
  OverlayEntry? _overlayEntry;

  void showOverlay(BuildContext context, String? title, String? body) {
    var overlay = Overlay.of(context);

    // chcek if theres already a pre existing overlay, and remove it if it exists

    // if (_overlayEntry == null) {
    //   print("No overlay found in the context.");
    //   return;
    // } else {
    //   _overlayEntry!.remove();
    // }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? "Alert!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  body ?? "Drive carefully!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                // ElevatedButton(
                //     onPressed: () {
                //       _overlayEntry!.remove();
                //     },
                //     child: Text(
                //       "OK",
                //       style: TextStyle(
                //         color: Colors.blue.shade700,
                //       ),
                //     ))
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);

    Future.delayed(Duration(seconds: 3), () {
      _overlayEntry!.remove();
    });
  }

  // Function to check if marker is inside radius of target coordinates
  void playSoundIfInRadius(LatLng marker, Map<LatLng, int> targetStatus,
      List<LatLng> targets, int alert) async {
    if (preferences[3][1]) {
      bool hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        final AudioPlayer player = AudioPlayer();

        double radius = 50; // 50 meters
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
              try {
                Vibration.vibrate(duration: 500);
                await player.setAsset('assets/noise.mp3');
                player.play();

                if (alert == 0) {
                  notifyIfInRadius("Alert!", "Steep slope approaching!");
                } else if (alert == 1) {
                  notifyIfInRadius("Alert!", "Sharp turn approaching!");
                }

                // Update target status after sound is played
                player.playerStateStream.listen((state) {
                  if (state.processingState == ProcessingState.completed) {
                    targetStatus[target] = 1;
                  }
                });
              } catch (e) {
                print("Error playing sound: $e");
              }
            }
          }
        }
      }
    }
  }

  void notifyIfInRadius(String title, String body) {
    if (preferences[4][1]) {
      _overlayEntry = null;
      showOverlay(context, title, body);
    }
  }

// <----------------------------------- SHARP TURNS ------------------------------------------>

  void generateBluePolylinesFromSharpTurns(
      List<LatLng> polylineCoordinates) async {
    if (preferences[1][1]) {
      // print("Starting sharp turn polyline generation"); // For debugging

      // Detect sharp turns
      List<List<LatLng>> sharpTurnPoints =
          TurnDetector().detectTurns(polylineCoordinates);
      print(sharpTurnPoints);

      Map<LatLng, int> startPointsMap = getStartPointsMap(sharpTurnPoints);
      List<LatLng> startPointsList = getStartPointsList(sharpTurnPoints);

      for (List<LatLng> segment in sharpTurnPoints) {
        PolylineId id =
            PolylineId('sharp_turn_${sharpTurnPoints.indexOf(segment)}');

        Polyline bluePolyline = Polyline(
          polylineId: id,
          color: Colors.blue.shade400,
          points: segment,
          width: 5,
        );

        setState(() {
          polylines[id] = bluePolyline;
          // print("Added blue polyline from sharp turn segment");
        });
      }
    }
  }
}
