import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/.env.dart';
// import 'package:safedrive/pages/directions_repository.dart';
import 'directions_model.dart';
import 'package:location/location.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DriveScreen extends StatefulWidget {
  DriveScreen({super.key});

  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  final LatLng initialLocation = LatLng(37.4223, -122.0848);
  // final LatLng _initialCameraPosition = LatLng(37.4223, -122.0848);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  final LatLng initialLocation = LatLng(37.4223, -122.0848);
  final LatLng _initialCameraPosition = LatLng(37.4223, -122.0848);

  LatLng originPoint = LatLng(23.6755568, 86.1604257);
  LatLng destinationPoint = LatLng(23.000000, 89.000000);
  Location _locationController = new Location();
  GoogleMapController? mapController;
  LatLng? _currentP = null;

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) => {
          getPolylinePoints().then((coordinates) => {print(coordinates)}),
        });
    _initializeMapRenderer();
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

  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  LatLng? _originPoint;
  LatLng? _destinationPoint;

  // Add marker
  void _addMarker(LatLng pos) async {
    if (_origin == null || _origin != null && _destination != null) {
      setState(
        () {
          _origin = Marker(
              markerId: const MarkerId("origin"),
              infoWindow: const InfoWindow(title: "Origin"),
              icon: BitmapDescriptor.defaultMarker,
              position: pos);
          _destination = null;
          _originPoint = LatLng(pos.latitude, pos.longitude);

          // Reset info
          _info = null;
          LatLng _initialCameraPosition = LatLng(pos.latitude, pos.longitude);
        },
      );
    } else {
      setState(
        () {
          _destination = Marker(
              markerId: const MarkerId("destination"),
              infoWindow: const InfoWindow(title: "Destination"),
              icon: BitmapDescriptor.defaultMarker,
              position: pos);
          _destinationPoint = LatLng(pos.latitude, pos.longitude);
        },
      );

      // Get directions
      // final directions = await DirectionsRepository().getDirections(
      //   origin: _origin!.position,
      //   destination: pos,
      // );
      // setState(() => _info = directions);
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
                          if (_origin != null) _origin!,
                          if (_destination != null) _destination!,

                          // Live location marker
                          Marker(
                            markerId: MarkerId("_currentLocation"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: _currentP!,
                          ),
                        },
                        polylines: {
                          _info != null
                              ? Polyline(
                                  polylineId:
                                      const PolylineId('overview_polyline'),
                                  color: Colors.red,
                                  width: 5,
                                  points: _info!.polylinePoints!
                                      .map((e) =>
                                          LatLng(e.latitude, e.longitude))
                                      .toList(),
                                )
                              : Polyline(polylineId: const PolylineId('null'))
                        },
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
                if (_info != null)
                  Positioned(
                    top: 20.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          )
                        ],
                      ),
                      child: Text(
                        '${_info?.totalDistance}, ${_info?.totalDuration}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () {
                if (_destination != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _destination!.position,
                        zoom: 14.5,
                      ),
                    ),
                  );
                }
              },
              mini: true,
              backgroundColor: Colors.white70,
              child: Text("D"),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 150,
            child: FloatingActionButton(
              onPressed: () {
                if (_origin != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _origin!.position,
                        zoom: 14.5,
                      ),
                    ),
                  );
                }
              },
              mini: true,
              backgroundColor: Colors.white70,
              child: Text("O"),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 200,
            child: FloatingActionButton(
              onPressed: () {
                _info != null
                    ? mapController?.animateCamera(
                        CameraUpdate.newLatLngBounds(_info!.bounds, 100.0),
                      )
                    : () {};
              },
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(Icons.center_focus_strong),
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
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPIKey,
        request: PolylineRequest(
          origin: PointLatLng(originPoint.latitude, originPoint.longitude),
          destination: PointLatLng(
              destinationPoint.latitude, destinationPoint.longitude),
          mode: TravelMode.driving,
        ));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }
}
