import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfflineMapPage extends StatefulWidget {
  const OfflineMapPage({super.key});

  @override
  State<OfflineMapPage> createState() => _OfflineMapPageState();
}

class _OfflineMapPageState extends State<OfflineMapPage> {
  Location _locationController = new Location();
  bool isOffline = true;
  LatLng? _currentP = LatLng(24, 86);

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

// Returns bounds based on a list of LatLng
  List<LatLngBounds> returnBoundsList(List<LatLng> locations) {
    List<LatLngBounds> boundsList = [];
    for (var location in locations) {
      double minLat = location.latitude - 0.01;
      double maxLat = location.latitude + 0.01;
      double minLng = location.longitude - 0.01;
      double maxLng = location.longitude + 0.01;

      LatLngBounds bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );
      boundsList.add(bounds);
    }

    return boundsList;
  }

// Converts latitude to tile Y coordinates
  int latToTileY(double lat, int zoom) {
    return ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) /
            2 *
            pow(2, zoom))
        .floor();
  }

// Converts longitude to tile X coordinates
  int lonToTileX(double lon, int zoom) {
    return ((lon + 180) / 360 * pow(2, zoom)).floor();
  }

// Function to download a single tile
  Future<void> downloadTile(int zoom, int x, int y, String savePath) async {
    String url = 'https://a.tile.openstreetmap.org/$zoom/$x/$y.png';
    Dio dio = Dio(); // To perform an http request to OpenStreetMap

    try {
      // Downloading the tile
      await dio.download(url, savePath);
      print('Tile $zoom/$x/$y downloaded to $savePath');
    } catch (e) {
      print('Error downloading tile $zoom/$x/$y: $e');
    }
  }

// Downloads all tiles for the given bounding boxes
  Future<void> downloadTilesForBoundingBox(
      LatLngBounds bounds, int zoom, String directoryPath) async {
    int minTileX = lonToTileX(bounds.southWest.longitude, zoom);
    int maxTileX = lonToTileX(bounds.northEast.longitude, zoom);
    int minTileY = latToTileY(bounds.northEast.latitude, zoom);
    int maxTileY = latToTileY(bounds.southWest.latitude, zoom);

    // Check if directory exists
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      // If directory doesn't exist
      await directory.create(recursive: true);
    }

    // Downloads each tile in the range
    for (int x = minTileX; x <= maxTileX; x++) {
      for (int y = minTileY; y <= maxTileY; y++) {
        String tilePath = '$directoryPath/$zoom/$x/$y.png';
        await downloadTile(zoom, x, y, tilePath);
      }
    }
  }

// Main function to handle download of tiles for all bounding boxes
  Future<void> downloadTilesForFavoritePlaces(
      List<LatLngBounds> boundsList) async {
    // Gets the app's documents directory where tiles will be stored
    final directory = await getApplicationDocumentsDirectory();
    final tileStorageDirectory = '${directory.path}/offline_tiles';

    // Loop through all the bounding boxes
    for (var bounds in boundsList) {
      await downloadTilesForBoundingBox(bounds, 15, tileStorageDirectory);
    }
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
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentP);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the path where the offline tiles are stored
    Future<String> getTilePath(int zoom, int x, int y) async {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/offline_tiles/$zoom/$x/$y.png';
    }

    return Scaffold(
      body: FutureBuilder<String>(
        future: getTilePath(15, 100, 100), // Example for a tile path
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tile path'));
          } else {
            String tilePath = snapshot.data!;

            return FlutterMap(
              options: MapOptions(
                initialCenter: _currentP ?? LatLng(24, 86),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'file://$tilePath', // Load the offline tile path
                  tileProvider: FileTileProvider(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
