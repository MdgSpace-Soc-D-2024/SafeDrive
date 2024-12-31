import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/.env.dart';
import 'directions_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

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
  TextEditingController textEditingController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _initializeMapRenderer();

    textEditingController.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(textEditingController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = googleAPIKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();

    print('data');
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load suggestions.');
    }
  }

  bool _isListViewVisible =
      false; // Boolean to track if the ListView should be visible
  TextEditingController searchBarEditingController = TextEditingController();

  void _toggleListViewVisibility() {
    setState(() {
      _isListViewVisible = !_isListViewVisible;
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

  Marker? _chosenLocation;
  Directions? _info;
  LatLng? _chosenLocationLatLng;

  // Add marker FUNCTION
  void _addMarker(LatLng pos) async {
    setState(
      () {
        _chosenLocation = Marker(
            markerId: const MarkerId("chosenLocation"),
            infoWindow: const InfoWindow(title: "Chosen Location"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos);

        // Reset info
        _info = null;
        _chosenLocationLatLng = LatLng(pos.latitude, pos.longitude);
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
                GestureDetector(
                  onTap: _toggleListViewVisibility,
                  child: GoogleMap(
                    markers: {
                      if (_chosenLocation != null) _chosenLocation!,
                    },
                    onLongPress: _addMarker,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: widget.initialLocation,
                      zoom: 15.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType:
                        MapType.normal, // Use normal map type for simplicity
                    zoomControlsEnabled:
                        true, // Disable zoom controls if not needed
                    compassEnabled: true, // Disable compass if not needed
                    padding: EdgeInsets.only(
                      top: 50,
                      bottom: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: TextFormField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: "Search a place...",
                      border: InputBorder.none,
                      // focusedBorder: InputBorder.none,
                      // enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      prefixIcon: Icon(Icons.search)),
                  onTap: _toggleListViewVisibility,
                ),
              ),
              _isListViewVisible && _placesList.length > 0
                  ? Flexible(
                      child: Container(
                        height: 300,
                        color: Colors.white70,
                        padding: EdgeInsets.all(10),
                        child: ListView.builder(
                            itemCount: _placesList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () async {
                                  List<Location> locations =
                                      await locationFromAddress(
                                          _placesList[index]['description']);
                                  print(locations.last.latitude);
                                  print(locations.last.longitude);
                                },
                                title: Text(_placesList[index]['description']),
                              );
                            }),
                      ),
                    )
                  : Container(),
            ],
          ),
          Positioned(
            right: 8,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () {
                if (_chosenLocationLatLng != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target:
                            _chosenLocationLatLng!, // Safely access _currentLocation
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
