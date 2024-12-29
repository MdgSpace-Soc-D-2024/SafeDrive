import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/directions_repository.dart';
import 'directions_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  // Locations
  final LatLng initialLocation = _pGooglePlex;
  // final LatLng _initialCameraPosition = LatLng(37.4223, -122.0848);
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
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
    _updateCamera();
  }

// Updates the camera to animate to a specific location when the app is initialized
  void _updateCamera() {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: widget.initialLocation,
        zoom: 15.0,
      ),
    ));
  }

  Marker? _currentLocation;
  Directions? _info;
  LatLng? _currentLocationLatLng;

  // Add marker FUNCTION
  void _addMarker(LatLng pos) async {
    setState(
      () {
        _currentLocation = Marker(
            markerId: const MarkerId("currentLocation"),
            infoWindow: const InfoWindow(title: "Current Location"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos);

        // Reset info
        _info = null;
        _currentLocationLatLng = LatLng(pos.latitude, pos.longitude);
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
                GoogleMap(
                  markers: {
                    if (_currentLocation != null) _currentLocation!,
                  },
                  onLongPress: _addMarker,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.initialLocation,
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal, // Use normal map type for simplicity
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search a place...",
                  border: InputBorder.none,
                  // focusedBorder: InputBorder.none,
                  // enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  prefixIcon: Icon(Icons.search)),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentLocationLatLng != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target:
                            _currentLocationLatLng!, // Safely access _currentLocation
                        zoom: 15.0, // Set the zoom level to 15
                      ),
                    ),
                  );
                } else {
                  // Do nothing if _currentLocation is null
                  // No need to do anything here, just leave this empty or handle null case as needed
                }
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
}
