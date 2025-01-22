// import 'package:latlong2/latlong.dart';

// class FavoritePlace {
//   double? latitude;
//   double? longitude;
//   String? name;

//   FavoritePlace({
//     required this.latitude,
//     required this.longitude,
//     required this.name,
//   });

//   FavoritePlace.fromJson(Map<String, Object?> json)
//       : this(
//           latitude: json['Latitude']! as double,
//           longitude: json['Longitude']! as double,
//           name: json['Name']! as String,
//         );

//   FavoritePlace copyWith({
//     double? latitude,
//     double? longitude,
//     String? name,
//   }) {
//     return FavoritePlace(
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       name: name ?? this.name,
//     );
//   }

//   Map<String, Object?> toJson() {
//     return {
//       "Latitude": latitude,
//       "Longitude": longitude,
//       "Name": name,
//     };
//   }
// }

// const String favoritePlaceCollectionReference = "favoritesList";

// class DatabaseService {
//   final _firestore = FirebaseFirestore.instance;

//   late final CollectionReference _favoritePlaceRef;

//   DatabaseService() {
//     _favoritePlaceRef = _firestore
//         .collection(favoritePlaceCollectionReference)
//         .withConverter<FavoritePlace>(
//             fromFirestore: (snapshots, _) => FavoritePlace.fromJson(
//                   snapshots.data()!,
//                 ),
//             toFirestore: (favoritePlace, _) => favoritePlace.toJson());
//   }

//   Stream<List<FavoritePlace>> getFavoritePlaces() {
//     return _favoritePlaceRef.snapshots().map((snapshot) {
//       print(snapshot.docs
//           .map((doc) => doc.data()!)
//           .whereType<FavoritePlace>()
//           .toList());
//       return snapshot.docs
//           .map((doc) => doc.data()!)
//           .whereType<FavoritePlace>()
//           .toList();
//     });
//   }

//   Future<List<Map<String, dynamic>>> getData() async {
//     try {
//       QuerySnapshot snapshot =
//           await _firestore.collection('favoritesList').get();

//       List<Map<String, dynamic>> items = snapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//       print(items);
//       return items;
//     } catch (e) {
//       print("Error retrieving data: $e");
//       return [];
//     }
//   }

//   Future<List<LatLng>> fetchLatLngList() async {
//     try {
//       // Fetch the documents from Firestore
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('favoritesList').get();

//       // Map the documents to a list of LatLng objects
//       List<LatLng> latLngList = snapshot.docs.map((doc) {
//         double lat = doc['Latitude'];
//         double lng = doc['Longitude'];

//         // Create LatLng object
//         return LatLng(lat, lng);
//       }).toList();

//       return latLngList;
//     } catch (e) {
//       print("Error fetching LatLng data: $e");
//       return [];
//     }
//   }

//   void addFavoritePlace(FavoritePlace favoritePlace) async {
//     _favoritePlaceRef.add(favoritePlace);
//   }
// }
