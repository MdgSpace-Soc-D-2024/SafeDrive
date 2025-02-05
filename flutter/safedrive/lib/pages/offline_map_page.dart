//
import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'package:safedrive/pages/drive_screen.dart';
//
import 'package:flutter_map/flutter_map.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drive_screen.dart';

LatLng? _currentP;

// Download tiles for offline use
Future<void> downloadTilesForOfflineUse() async {
  List<LatLng> latLngList = await DatabaseService().fetchLatLngList();
  if (_currentP != null) {
    latLngList.add(_currentP!);
  }
  List<LatLngBounds> latLngBoundsList = returnBoundsList(latLngList);
  downloadTilesForFavoritePlaces(latLngBoundsList);
}

class OfflineMapPage extends StatefulWidget {
  const OfflineMapPage({super.key});

  @override
  State<OfflineMapPage> createState() => _OfflineMapPageState();
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

  LatLngBounds specialBound = LatLngBounds(
    LatLng(22.99, 85.99),
    LatLng(23.01, 86.01),
  );
  boundsList.add(specialBound);
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

List<List<int>> downloadedTiles = [];
// Downloads all tiles for the given bounding boxes
Future<void> downloadTilesForBoundingBox(
    LatLngBounds bounds, int zoom, String directoryPath) async {
  int minTileX = lonToTileX(bounds.southWest.longitude, zoom);
  int maxTileX = lonToTileX(bounds.northEast.longitude, zoom);
  int minTileY = latToTileY(bounds.northEast.latitude, zoom);
  int maxTileY = latToTileY(bounds.southWest.latitude, zoom);

  downloadedTiles = [];

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
      downloadedTiles.add([zoom, x, y]);
      await downloadTile(zoom, x, y, tilePath);
    }
  }

  print("DOWNLOADED!!");
  print(downloadedTiles);
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

class _OfflineMapPageState extends State<OfflineMapPage> {
  Location _locationController = new Location();
  bool isOffline = true;
  LatLng? _currentP = LatLng(24, 86);

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
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    // Define the path where the offline tiles are stored
    Future<String> getTilePath(int zoom, int x, int y) async {
      final directory = await getApplicationDocumentsDirectory();
      // String tilePath = p.join(directory.path, 'offline_tiles');
      String tilePath =
          '/data/user/0/com.safedrive.app/app_flutter/offline_tiles';
      return tilePath;
    }

    final mapController = MapController();

    return Scaffold(
      body: FutureBuilder<void>(
        future: completed,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tile path'));
          } else {
            String tilePath =
                '/data/user/0/com.safedrive.app/app_flutter/offline_tiles';

            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(downloadedTiles[0][1].toDouble(),
                    downloadedTiles[0][2].toDouble()),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'file://$tilePath/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safedrive',
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

// Managing favorites
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

const String favoritePlaceCollectionReference = "favoritesList";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _favoritePlaceRef;

  // the following method runs when the class is initialized, to set up logic and initialize values
  DatabaseService() {
    _favoritePlaceRef = _firestore
        .collection(favoritePlaceCollectionReference)
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
        double lat = (doc['Latitude'] is int)
            ? (doc['Latitude'] as int).toDouble()
            : doc['Latitude'];
        double lng = (doc['Longitude'] is int)
            ? (doc['Longitude'] as int).toDouble()
            : doc['Longitude'];

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
