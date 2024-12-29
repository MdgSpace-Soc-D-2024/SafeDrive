// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

// class MapScreen extends StatefulWidget {
//   final LatLng initialLocation = _pGooglePlex;

//   const MapScreen({super.key});

//   static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;

//   @override
//   void initState() {
//     super.initState();
//     _initializeMapRenderer();
//   }

//   void _initializeMapRenderer() {
//     final GoogleMapsFlutterPlatform mapsImplementation =
//         GoogleMapsFlutterPlatform.instance;
//     if (mapsImplementation is GoogleMapsFlutterAndroid) {
//       mapsImplementation.useAndroidViewSurface = true;
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     _updateCamera();
//   }

//   void _updateCamera() {
//     mapController?.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: widget.initialLocation,
//         zoom: 15.0,
//       ),
//     ));
//   }

//   @override
//   void dispose() {
//     mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(
//             target: widget.initialLocation,
//             zoom: 15.0,
//           ),
//           myLocationEnabled: true,
//           myLocationButtonEnabled: true,
//           mapType: MapType.normal, // Use normal map type for simplicity
//           zoomControlsEnabled: false, // Disable zoom controls if not needed
//           compassEnabled: false, // Disable compass if not needed
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // // import 'package:searchbar_animation/searchbar_animation.dart';

// // int counter = 0;

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   State<MapScreen> createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: GoogleMap(
// //           initialCameraPosition: CameraPosition(target: _pGooglePlex)),
// //     );
// //   }
// // }

// // // class MapScreen extends StatefulWidget {
// // //   const MapScreen({super.key});

// // //   @override
// // //   State<MapScreen> createState() => _MapScreenState();
// // // }

// // // class _MapScreenState extends State<MapScreen> {
// // //   static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Stack(
// // //         children: [
// // //           Container(
// // //             width: double.infinity,
// // //             height: double.infinity,
// // //           ),
// // //           GoogleMap(
// // //             initialCameraPosition: CameraPosition(target: _pGooglePlex),
// // //           ),
// // //           SearchBarAnimation(
// // //             textEditingController: TextEditingController(),
// // //             isOriginalAnimation: false,
// // //             buttonBorderColour: Colors.black45,
// // //             trailingWidget: Icon(Icons.search),
// // //             buttonWidget: Icon(Icons.search),
// // //             secondaryButtonWidget: Icon(Icons.arrow_right_alt),
// // //             onFieldSubmitted: (String value) {
// // //               debugPrint('onFieldSubmitted value $value');
// // //             },
// // //           ),
// // //           Positioned(
// // //             bottom: 20,
// // //             right: 20,
// // //             child: ElevatedButton(
// // //               style: TextButton.styleFrom(
// // //                   padding: EdgeInsets.all(25),
// // //                   backgroundColor: Color.fromARGB(255, 241, 70, 70)),
// // //               onPressed: () {
// // //                 // print('button pressed!');
// // //               },
// // //               child: Icon(
// // //                 Icons.favorite_outlined,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class MapScreen extends StatelessWidget {
// // //   const MapScreen({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Stack(
// // //         children: [
// // //           Container(
// // //             width: double.infinity,
// // //             height: double.infinity,
// // //           ),
// // //           GoogleMap(initialCameraPosition: null,),
// // //           SearchBarAnimation(
// // //             textEditingController: TextEditingController(),
// // //             isOriginalAnimation: false,
// // //             buttonBorderColour: Colors.black45,
// // //             trailingWidget: Icon(Icons.search),
// // //             buttonWidget: Icon(Icons.search),
// // //             secondaryButtonWidget: Icon(Icons.arrow_right_alt),
// // //             onFieldSubmitted: (String value) {
// // //               debugPrint('onFieldSubmitted value $value');
// // //             },
// // //           ),
// // //           Positioned(
// // //             bottom: 20,
// // //             right: 20,
// // //             child: ElevatedButton(
// // //               style: TextButton.styleFrom(
// // //                   padding: EdgeInsets.all(25),
// // //                   backgroundColor: Color.fromARGB(255, 241, 70, 70)),
// // //               onPressed: () {
// // //                 // print('button pressed!');
// // //               },
// // //               child: Icon(
// // //                 Icons.favorite_outlined,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
