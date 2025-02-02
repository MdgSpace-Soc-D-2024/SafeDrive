import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safedrive/pages/drive_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// shared preferences

// load last location from shared preferences
Future<LatLng> loadLastLocation() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  double? lat = prefs.getDouble('lastLatitude');
  double? lng = prefs.getDouble('lastLongitude');

  if (lat == null || lng == null) {
    return LatLng(37.4223, -122.0848);
  } else {
    return LatLng(lat, lng);
  }
}

// connectivity services

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

// firebase notification services

class FirebaseApi {
  // function to initialize notifications
  Future<void> initNotifications() async {
    // create an instance of firebase messaging
    final _firebaseMessaging = FirebaseMessaging.instance;

    // request permissions from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // print the token
    print("Token: $fCMToken");
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotiService {
//   final notificationsPlugin = FlutterLocalNotificationsPlugin();

//   bool _isInitialized = false;

//   bool get isIntialized => _isInitialized;

//   // Initialize
//   Future<void> initNotifications() async {
//     if (_isInitialized) return;

//     const initSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const initSettingIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingIOS,
//     );

//     await notificationsPlugin.initialize(initSettings);
//   }

//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         "alert_id",
//         "Alert!",
//         channelDescription: "Alert",
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//   }

//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//   }) async {
//     return notificationsPlugin.show(
//       id,
//       title,
//       body,
//       const NotificationDetails(),
//     );
//   }
// }
