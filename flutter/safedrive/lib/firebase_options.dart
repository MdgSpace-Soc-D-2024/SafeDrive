// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqt462o2C2migwAFNo7FyJcOHhPJR5P7c',
    appId: '1:211561372369:web:af753ba302d32da11543f0',
    messagingSenderId: '211561372369',
    projectId: 'safedrive-c694c',
    authDomain: 'safedrive-c694c.firebaseapp.com',
    storageBucket: 'safedrive-c694c.firebasestorage.app',
    measurementId: 'G-D3E4G0ETCV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfyH71_LwL0T4uO-kFGP6xP_w9c3cTbNg',
    appId: '1:211561372369:android:aad50b56847874921543f0',
    messagingSenderId: '211561372369',
    projectId: 'safedrive-c694c',
    storageBucket: 'safedrive-c694c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdMkwMYv_sOcChtbYqQT8Z4xu8CA9ujBo',
    appId: '1:211561372369:ios:cea1e8370331587d1543f0',
    messagingSenderId: '211561372369',
    projectId: 'safedrive-c694c',
    storageBucket: 'safedrive-c694c.firebasestorage.app',
    iosBundleId: 'com.example.safedrive',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdMkwMYv_sOcChtbYqQT8Z4xu8CA9ujBo',
    appId: '1:211561372369:ios:cea1e8370331587d1543f0',
    messagingSenderId: '211561372369',
    projectId: 'safedrive-c694c',
    storageBucket: 'safedrive-c694c.firebasestorage.app',
    iosBundleId: 'com.example.safedrive',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqt462o2C2migwAFNo7FyJcOHhPJR5P7c',
    appId: '1:211561372369:web:e3d613c7d70785a31543f0',
    messagingSenderId: '211561372369',
    projectId: 'safedrive-c694c',
    authDomain: 'safedrive-c694c.firebaseapp.com',
    storageBucket: 'safedrive-c694c.firebasestorage.app',
    measurementId: 'G-2RDPYJYBNR',
  );

}