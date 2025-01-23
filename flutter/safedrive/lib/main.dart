import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safedrive/firebase_options.dart';
import 'package:safedrive/pages/drivescreen.dart';
import 'package:safedrive/pages/offline_map_page.dart';
import 'package:safedrive/pages/settingscreen.dart';
import 'package:safedrive/pages/mapscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

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

class ConnectivityService extends ChangeNotifier {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  ConnectivityService() {
    // Listen for connectivity changes
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _checkConnectivity(result);
    });
  }

  // Check connectivity based on results
  Future<void> _checkConnectivity(List<ConnectivityResult> result) async {
    // Check if any of the results are none
    bool isOffline = result.contains(ConnectivityResult.none);

    if (isOffline != _isOffline) {
      _isOffline = isOffline;
      notifyListeners();
    }
  }
}

// Define a custom MaterialColor using the shades
MaterialColor myCustomMaterialColor = MaterialColor(0xFFE0E1DD, customSwatch);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
        create: (context) => ConnectivityService(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Changes the color of the status bar so it is visible
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp(
      title: 'SafeDrive',
      theme: ThemeData(
          primarySwatch: Colors.indigo, // Apply the custom color swatch
          textTheme: TextTheme(
            displayLarge: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 40,
                fontWeight: FontWeight.bold),
            displayMedium: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 34,
                fontWeight: FontWeight.bold),
            displaySmall: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 27,
                fontWeight: FontWeight.normal),
            headlineLarge: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w500),
            titleLarge: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 19,
                fontWeight: FontWeight.bold),
            titleMedium: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600),
            titleSmall: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400),
            bodyLarge: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.normal),
            bodySmall: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.normal),
            labelLarge: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600),
            labelMedium: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500),
            labelSmall: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w400),
          )),
      home: MyHomePage(),
      routes: {
        '/mapscreen': (context) => MapScreen(),
        '/drivescreen': (context) => DriveScreen(),
        '/settingscreen': (context) => SettingScreen(),
        '/offlinemappage': (context) => OfflineMapPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 2;
  final List<Widget> _screens = [
    MapScreen(),
    DriveScreen(),
    SettingScreen(),
    OfflineMapPage(),
  ];

  // Function to add delay before switching screen
  Future<void> _onItemTapped(int index) async {
    // await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
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
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_off_outlined),
            label: 'Offline',
          )
        ],
      ),
    );
  }
}
