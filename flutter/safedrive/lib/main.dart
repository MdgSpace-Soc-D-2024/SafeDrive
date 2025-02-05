// FUTURE UPDATES
// Detecting places like highways where even a smoother turn could be dangerous, using speed and locations to assess whether a turn is dangerous or not
// Longer vibrations / special sound when the user crosses a certain speed

// Firebase Notification
// Offline Maps
// Add dark mode to shared preferences
// Timeout for firestore requests showing "Check your network"

// Chunking the route and calculating the elevation only for 1 km  for more accurate results
// Splitting the code into smaller, reusable components instead of one big chunk

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safedrive/firebase_options.dart';
import 'package:safedrive/pages/drive_screen.dart';
import 'package:safedrive/pages/offline_map_page.dart';
import 'package:safedrive/pages/onboarding_screen.dart';
import 'package:safedrive/pages/setting_screen.dart';
import 'package:safedrive/pages/map_screen.dart';
import 'package:safedrive/services/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:safedrive/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ConnectivityService extends ChangeNotifier {
//   bool _isOffline = false;
//   bool get isOffline => _isOffline;

//   ConnectivityService() {
//     // Listen for connectivity changes
//     Connectivity()
//         .onConnectivityChanged
//         .listen((List<ConnectivityResult> result) {
//       _checkConnectivity(result);
//     });
//   }

//   // Check connectivity based on results
//   Future<void> _checkConnectivity(List<ConnectivityResult> result) async {
//     // Check if any of the results are none
//     bool isOffline = result.contains(ConnectivityResult.none);

//     if (isOffline != _isOffline) {
//       _isOffline = isOffline;
//       notifyListeners();
//     }
//   }
// }

void main() async {
  // widgets
  WidgetsFlutterBinding.ensureInitialized();

  // firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  // providers
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ConnectivityService(),
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // changes the color of the status bar so it is visible
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp(
      title: 'SafeDrive',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: FutureBuilder<bool>(
          future: _checkFirstLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data == true) {
              return OnboardingScreen();
            } else {
              return MyHomePage();
            }
          }),
      debugShowCheckedModeBanner: false,
      routes: {
        '/mapscreen': (context) => MapScreen(),
        '/drivescreen': (context) => DriveScreen(),
        '/settingscreen': (context) => SettingScreen(),
        '/offlinemappage': (context) => OfflineMapPage(),
      },
    );
  }

  Future<bool> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    return isFirstLaunch;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;
  final List<Widget> _screens = [
    MapScreen(),
    DriveScreen(),
    SettingScreen(),
    OfflineMapPage(),
  ];

  // add delay before switching screen
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
