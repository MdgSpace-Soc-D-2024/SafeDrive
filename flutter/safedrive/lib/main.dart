import 'package:flutter/material.dart';
import 'package:safedrive/firebase_options.dart';
import 'package:safedrive/pages/drivescreen.dart';
import 'package:safedrive/pages/settingscreen.dart';
import 'package:safedrive/pages/mapscreen.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_core/firebase_core.dart';

Color darkBlue = Color(0xFF0D1B2A); // Dark Blue
Color deepBlue = Color(0xFF1B263B); // Deep Blue
Color steelBlue = Color(0xFF415A77); // Steel Blue
Color lightSteelBlue = Color(0xFF778DA9); // Light Steel Blue
Color lightGray = Color(0xFFE0E1DD); // Light Gray

// Interpolated Colors (to create 9 shades in reverse order)
Map<int, Color> customSwatch = {
  50: Color.fromRGBO(224, 225, 221, 0.1), // Light Gray with 10% opacity
  100: Color.lerp(lightGray, lightSteelBlue, 0.2)!,
  200: Color.lerp(lightGray, lightSteelBlue, 0.4)!,
  300: Color.lerp(lightSteelBlue, steelBlue, 0.2)!,
  400: Color.lerp(lightSteelBlue, steelBlue, 0.4)!,
  500: steelBlue, // Base Color: Steel Blue
  600: Color.lerp(steelBlue, deepBlue, 0.2)!,
  700: Color.lerp(steelBlue, deepBlue, 0.4)!,
  800: Color.lerp(deepBlue, darkBlue, 0.2)!,
  900: Color.fromRGBO(13, 27, 42, 0.9), // Dark Blue with 90% opacity
};

// Define a custom MaterialColor using the shades
MaterialColor myCustomMaterialColor = MaterialColor(0xFFE0E1DD, customSwatch);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeDrive',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Apply the custom color swatch
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  int _currentIndex = 0;
  final List<Widget> _screens = [
    MapScreen(),
    DriveScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SafeDrive'),
        foregroundColor: lightGray,
        backgroundColor: Colors.black,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: darkBlue,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation_rounded),
            label: 'Drive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
    );
  }
}
