import 'package:firebase_messaging/firebase_messaging.dart';

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
