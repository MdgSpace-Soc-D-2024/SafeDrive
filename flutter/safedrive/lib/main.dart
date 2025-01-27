// Sound
// Firebase Notifiication
// Traffic (?)
// Offline Maps

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
import 'package:safedrive/themes/light_mode.dart';
import 'package:safedrive/themes/theme_provider.dart';

// Interpolated Colors (to create 9 shades in reverse order)
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    // Changes the color of the status bar so it is visible
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp(
      title: 'SafeDrive',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
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
  int _currentIndex = 1;
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
