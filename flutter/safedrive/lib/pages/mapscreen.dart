import 'dart:convert';
import 'package:flutter/rendering.dart';

import '../models/misc.dart';
import 'drivescreen.dart';
import 'package:safedrive/main.dart';
import 'favoritespage.dart';
import 'package:safedrive/pages/.env.dart';
import 'package:uuid/uuid.dart';
// Google
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
// Requests
import 'package:http/http.dart' as http;

LatLng driveScreenDestination = LatLng(0, 0);

// Wanted to use this so that the user could click on "Drive" in favorites and be led to Drive Screen but it didn't work unfortunately -- will fix later
void importToDriveScreen(LatLng coordinates) {
  driveScreenDestination = coordinates;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  // Locations
  // Will use Cloud Firebase to record the last location User was at and make that the initial location on the Google Maps
  final LatLng initialLocation = _pGooglePlex;
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

    // For search bar
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

  // Making requests
  void getSuggestion(String input) async {
    String kPLACES_API_KEY = googleAPIKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    // var data = response.body.toString();
    // print('data');

    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load suggestions.');
    }
  }

  bool _isListViewVisible =
      false; // Boolean to track if the search results should be visible so as to not block the view of Google Maps
  TextEditingController searchBarEditingController = TextEditingController();

  // Used to toggle the visibility of suggestions
  void _toggleListViewVisibility() {
    setState(() {
      _isListViewVisible = !_isListViewVisible;
    });
  }

  // Checks if our platform is Android to improve performance
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

  Marker? _chosenLocation; // To store the marker
  LatLng? _chosenLocationLatLng; // To store the marker's location

  // Adding a marker
  void _addMarker(LatLng pos) async {
    setState(
      () {
        _chosenLocation = Marker(
            markerId: const MarkerId("chosenLocation"),
            infoWindow: const InfoWindow(title: "Chosen Location"),
            icon: BitmapDescriptor.defaultMarker,
            position: pos,
            onTap: () async {
              // Asks if the user wants to add this location to the favorites
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                    // Google Maps
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
                      zoomControlsEnabled: true,
                      compassEnabled: true,
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
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    color:
                        Theme.of(context).colorScheme.tertiary.withAlpha(200),
                  ),
                  // Search Bar
                  child: TextFormField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: "Search for a place...",
                        hintStyle: TextStyle(
                            // color: Theme.of(context).colorScheme.tertiary,
                            ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: _toggleListViewVisibility,
                          // Toggles the suggestions' invisibility on tapping the search bar so that the map can be accessed with ease,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Icon(
                              Icons.remove_red_eye,
                            ),
                          ),
                        ),
                        iconColor: Theme.of(context).colorScheme.primary),
                  ),
                ),
                _isListViewVisible && _placesList.length > 0
                    // The list is visible only if its visibility is toggled on and the suggestions generated by Google Places API is not empty
                    ? Flexible(
                        child: Container(
                          height: 300,
                          padding: EdgeInsets.all(5),
                          child: ListView.builder(
                              itemCount: _placesList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary
                                          .withAlpha(200),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    onTap: () async {
                                      List<Location> locations =
                                          await locationFromAddress(
                                              _placesList[index]
                                                  ['description']);
                                      // print(locations.last.latitude);
                                      // print(locations.last.longitude);

                                      // Moves the camera to the tapped on location
                                      LatLng locationsLatLng = LatLng(
                                          locations.last.latitude,
                                          locations.last.longitude);
                                      _addMarker(locationsLatLng);
                                      mapController?.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: locationsLatLng,
                                            zoom: 15.0,
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      _placesList[index]['description'],
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
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
              // Button to move the camera to the location marker if we wander off
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
                          insetPadding: EdgeInsets.all(10),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            width: MediaQuery.of(context).size.width * 0.90,
                            decoration: BoxDecoration(),
                            child: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                  child: Text(
                                    "Favorites",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 1.3,
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
                                                // The favorited locations on being tapped lead to the location on Google Maps
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          SizedBox(width: 8),
                                                          // Delete button
                                                          ElevatedButton.icon(
                                                            style: ButtonStyle(
                                                              elevation:
                                                                  WidgetStateProperty
                                                                      .all(0),
                                                              shape:
                                                                  WidgetStateProperty
                                                                      .all(
                                                                RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          1), // Border color and width
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20), // Border radius
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "favoritesList")
                                                                  .doc(snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .delete();
                                                            },
                                                            icon: Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red),
                                                            label: Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .inversePrimary),
                                                            ),
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
            Positioned(
              right: 8,
              bottom: 200,
              // Button to move the camera to the location marker if we wander off
              child: FloatingActionButton(
                onPressed: () async {
                  LatLng? currentLocation = await getCurrentLocationOnce();
                  if (currentLocation != null) {
                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: currentLocation,
                          zoom: 16.0,
                        ),
                      ),
                    );
                  } else {
                    // Do nothing
                  }
                },
                elevation: 3,
                mini: true,
                child: Icon(Icons.zoom_in_map),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
