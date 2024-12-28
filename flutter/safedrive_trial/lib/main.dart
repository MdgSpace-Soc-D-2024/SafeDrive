import 'package:flutter/material.dart';
import 'package:safedrive_trial/screens/drivescreen.dart';
import 'package:safedrive_trial/screens/mapscreen.dart';
import 'package:safedrive_trial/screens/settingscreen.dart';

// Define custom colors using hex values
Color myCustomColor1 = Color(0xFFEDD9ED); // Light pink color
Color myCustomColor2 = Color(0xFFBE90A7); // Light pinkish color
Color myCustomColor3 = Color(0xFF505E79); // Grayish blue color
Color myCustomColor4 = Color(0xFF20304A); // Dark blue color
Color myCustomColor5 = Color(0xFF030512); // Very dark color (almost black)

// Custom MaterialColor swatch with shades
Map<int, Color> customSwatch = {
  50: Color(0x1FEDD9ED), // Light pink with reduced alpha
  100: Color(0x33EDD9ED), // Light pink with more opacity
  200: Color(0x4DEDD9ED), // Light pink with higher opacity
  300: Color(0x66EDD9ED), // More opacity
  400: Color(0x80EDD9ED), // Strong opacity
  500: myCustomColor1, // Base color (fully opaque)
  600: Color(0xB8BE90A7), // Light pinkish with more opacity
  700: Color(0xCC505E79), // Grayish blue with more opacity
  800: Color(0xE620304A), // Dark blue with more opacity
  900: Color(0xFF030512), // Very dark (almost black)
};

// Define a custom MaterialColor using the shades
MaterialColor myCustomMaterialColor = MaterialColor(0xFFEDD9ED, customSwatch);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // serves as an entry point for the app, so we define key settings here like the theme
  const MyApp({super.key});

  @override //overrides a method from its parents ie stateless widgets(the thing it extends from)
  Widget build(BuildContext context) {
    //build method is called whenever a widget needs to be displayed or updated on the screen -- essential for all widgets
    return MaterialApp(
      // allows us to use the material design ui for the whole app since we use it in MyApp
      // manages global configurations like themes, routing, localization, etc
      title:
          'SafeDrive', //reflected in the task manager, doesnt directly affect ui
      theme: ThemeData(
        primarySwatch: myCustomMaterialColor, //color palette for the entire app
        colorScheme: ColorScheme.fromSeed(seedColor: myCustomColor3),
        useMaterial3: true,
      ),
      home:
          MyHomePage(), //sets the first screen that appears when the app launchs, in this case MyHomePage
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;
  final List<Widget> _screens = [
    //creating a private list of the various screens we have corr. to the widgets in the navbar
    MapScreen(),
    DriveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //heading or the appname
        title: Text('SafeDrive'),
        foregroundColor: myCustomColor1,
        backgroundColor: myCustomColor5,
      ),
      body: _screens[
          _currentIndex], // the actual body part which corresponds to the 3 different screens
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: myCustomColor5,
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
          ),
        ],
      ),
    );
  }
}
