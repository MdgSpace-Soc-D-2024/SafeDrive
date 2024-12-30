import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/.env.dart';
import 'directions_model.dart';
import 'package:location/location.dart';

class DriveScreen extends StatefulWidget {
  DriveScreen({super.key});

  final LatLng initialLocation = LatLng(37.4223, -122.0848);

  @override
  _DriveScreenState createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  final LatLng initialLocation = LatLng(37.4223, -122.0848);
  final LatLng _initialCameraPosition = LatLng(37.4223, -122.0848);

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
    getLocationUpdates().then((_) => {
          getPolylinePoints().then((coordinates) => {
                generatePolylineFromPoints(coordinates),
              }),
        });
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
  bool _isRouteButtonEnabled = false;

  // Add marker
  void _addMarker(LatLng pos) async {
    setState(
      () async {
        _destination = Marker(
            markerId: const MarkerId("_destination"),
            infoWindow: const InfoWindow(title: "Destination"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos);

        // Reset info
        _info = null;
        _destinationPoint = LatLng(pos.latitude, pos.longitude);
        _isRouteButtonEnabled = true;

        // if (_currentP != null && _destinationPoint != null) {
        //   List<LatLng> polylineCoordinates = await getPolylinePoints();
        //   generatePolylineFromPoints(polylineCoordinates);
        // }
      },
    );
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
        // if (_destinationPoint != null) {
        //   getPolylinePoints();
        // }
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
        destination:
            PointLatLng(destinationPoint.latitude, destinationPoint.longitude),
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
      color: Colors.blue.shade300,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}
