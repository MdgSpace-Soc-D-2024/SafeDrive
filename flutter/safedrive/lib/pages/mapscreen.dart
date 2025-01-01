import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'favoritespage.dart';

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
  // For search bar functionality
  TextEditingController textEditingController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

  // For maps functionality
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

  // Used to toggle the visibility of suggestions
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
  LatLng? _chosenLocationLatLng;

  // Add marker FUNCTION
  void _addMarker(LatLng pos) async {
    setState(
      () {
        _chosenLocation = Marker(
            markerId: const MarkerId("chosenLocation"),
            infoWindow: const InfoWindow(title: "Chosen Location"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos,
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Add this location to favorites?"),
                      content: Text(
                          "Would you like to add the location at ${pos.latitude}, ${pos.longitude} to your favorites?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // No, don't add
                          },
                          child: Text("No"),
                        ),
                        TextButton(
                            onPressed: () async {
                              String addressName = await changeLatLngToAddress(
                                  pos.latitude, pos.longitude);
                              uploadTaskToDb(
                                  addressName, pos.latitude, pos.longitude);
                              Navigator.of(context)
                                  .pop(true); // Yes, add to favorites
                              favoritesList
                                  .add(LatLng(pos.latitude, pos.longitude));
                            },
                            child: Text("Yes"))
                      ],
                    );
                  });
            });

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
                ),
                child: TextFormField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: "Search a place...",
                      border: InputBorder.none,
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
                                  // print(locations.last.latitude);
                                  // print(locations.last.longitude);

                                  // Animating camera to given location when tapped on
                                  LatLng locationsLatLng = LatLng(
                                      locations.last.latitude,
                                      locations.last.longitude);
                                  _addMarker(locationsLatLng);
                                  mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target:
                                            locationsLatLng, // Safely access _currentLocation
                                        zoom: 15.0, // Set the zoom level to 15
                                      ),
                                    ),
                                  );
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
                        target: _chosenLocationLatLng!,
                        zoom: 15.0,
                      ),
                    ),
                  );
                } else {
                  // Do nothing if _currentLocation is null
                }
              },
              elevation: 3,
              mini: true,
              backgroundColor: Colors.white,
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
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(snapshot
                                                  .data!.docs[index]
                                                  .data()['Name']),
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
}
