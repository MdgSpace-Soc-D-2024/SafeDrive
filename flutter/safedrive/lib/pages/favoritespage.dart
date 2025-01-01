import 'package:flutter/material.dart';
import 'mapscreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

// A list to store favorites
List<LatLng> favoritesList = [];

// Function to convert coordinates to an address name
Future<String> changeLatLngToAddress(latitude, longitude) async {
  List<Placemark> placemarks = await GeocodingPlatform.instance!
      .placemarkFromCoordinates(latitude, longitude);
  Placemark placemark = placemarks.first;
  String _address =
      '${placemark.street}, ${placemark.locality}, ${placemark.country}';
  print(_address);
  return _address;
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
    print(data.id);
  } catch (e) {
    print(e);
  }
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
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
            Expanded(
              child: ListView.builder(
                  itemCount: favoritesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(favoritesList[index].toString()),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
