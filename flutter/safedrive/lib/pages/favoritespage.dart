// <---------------------------------- NOT IN USE ---------------------------------->

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class FavoritePlace {
  double? latitude;
  double? longitude;
  String? name;

  FavoritePlace({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  FavoritePlace.fromJson(Map<String, Object?> json)
      : this(
          latitude: json['Latitude']! as double,
          longitude: json['Longitude']! as double,
          name: json['Name']! as String,
        );

  FavoritePlace copyWith({
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return FavoritePlace(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "Latitude": latitude,
      "Longitude": longitude,
      "Name": name,
    };
  }
}

const String FavoritePlaceCollectionReference = "favoritesList";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _favoritePlaceRef;

  DatabaseService() {
    _favoritePlaceRef = _firestore
        .collection(FavoritePlaceCollectionReference)
        .withConverter<FavoritePlace>(
            fromFirestore: (snapshots, _) => FavoritePlace.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (favoritePlace, _) => favoritePlace.toJson());
  }

  Stream<List<FavoritePlace>> getFavoritePlaces() {
    return _favoritePlaceRef.snapshots().map((snapshot) {
      print(snapshot.docs
          .map((doc) => doc.data()!)
          .whereType<FavoritePlace>()
          .toList());
      return snapshot.docs
          .map((doc) => doc.data()!)
          .whereType<FavoritePlace>()
          .toList(); // safely unwraps the FavoritePlace object
    });
  }

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('favoritesList').get();

      List<Map<String, dynamic>> items = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print(items);
      return items;
    } catch (e) {
      print("Error retrieving data: $e");
      return [];
    }
  }

  Future<List<LatLng>> fetchLatLngList() async {
    try {
      // Fetch the documents from Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('favoritesList').get();

      // Map the documents to a list of LatLng objects
      List<LatLng> latLngList = snapshot.docs.map((doc) {
        double lat = doc['Latitude']; // Assuming field name is 'latitude'
        double lng = doc['Longitude'];

        // Create LatLng object
        return LatLng(lat, lng);
      }).toList();

      return latLngList;
    } catch (e) {
      print("Error fetching LatLng data: $e");
      return [];
    }
  }

  void addFavoritePlace(FavoritePlace favoritePlace) async {
    _favoritePlaceRef.add(favoritePlace);
  }
}

// A list to store favorites
List<LatLng> favoritesList = [];

// Function to convert coordinates to an address name
Future<String> changeLatLngToAddress(latitude, longitude) async {
  List<Placemark> placemarks = await GeocodingPlatform.instance!
      .placemarkFromCoordinates(latitude, longitude);
  Placemark placemark = placemarks.first;
  String address =
      '${placemark.street}, ${placemark.locality}, ${placemark.country}';

  return address;
}

// Function to upload locations to favorites
Future<void> uploadTaskToDb(name, latitude, longitude) async {
  try {
    final data =
        await FirebaseFirestore.instance.collection("favoritesList").add({
      "Name": name,
      "Latitude": latitude,
      "Longitude": longitude,
    }); // Only one instance is created every single time
  } catch (e) {
    // do something
  }
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "Favorites",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("favoritesList")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData) {
                return const Text("No favorited locations yet.");
              } else {
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length - 1,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        return GestureDetector(
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['Name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Drive to
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: Icon(Icons.directions_car),
                                      label: Text("Drive"),
                                    ),
                                    SizedBox(width: 8),
                                    // Delete button
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection("favoritesList")
                                            .doc(snapshot.data!.docs[index].id)
                                            .delete();
                                      },
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
