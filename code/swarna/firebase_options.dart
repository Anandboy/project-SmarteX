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
    /// Returns Firebase configuration based on the current platform.
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
/// Firebase configuration for web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJyDucijgqStg2TrCbXeDfT6e5edULljE',
    appId: '1:188961519445:web:29b111c2fa82467e9ae1dc',
    messagingSenderId: '188961519445',
    projectId: 'farmers-b8a11',
    authDomain: 'farmers-b8a11.firebaseapp.com',
    storageBucket: 'farmers-b8a11.firebasestorage.app',
    measurementId: 'G-S8P5Y7YF68',
  );
 /// Firebase configuration for Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCp4MDww3r7zIi_peS_VT_7LgJR5OLJxaI',
    appId: '1:188961519445:android:b8de403e42dd230e9ae1dc',
    messagingSenderId: '188961519445',
    projectId: 'farmers-b8a11',
    storageBucket: 'farmers-b8a11.firebasestorage.app',
  );
/// Firebase configuration for iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDNBZofiMQ9X6xPzLD3dbxg1V_dTVNZN5A',
    appId: '1:188961519445:ios:e91496075f10a8419ae1dc',
    messagingSenderId: '188961519445',
    projectId: 'farmers-b8a11',
    storageBucket: 'farmers-b8a11.firebasestorage.app',
    iosBundleId: 'com.example.personalExpenseTracker',
  );
/// Firebase configuration for macOS (same as iOS).
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDNBZofiMQ9X6xPzLD3dbxg1V_dTVNZN5A',
    appId: '1:188961519445:ios:e91496075f10a8419ae1dc',
    messagingSenderId: '188961519445',
    projectId: 'farmers-b8a11',
    storageBucket: 'farmers-b8a11.firebasestorage.app',
    iosBundleId: 'com.example.personalExpenseTracker',
  );
/// Firebase configuration for Windows.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJyDucijgqStg2TrCbXeDfT6e5edULljE',
    appId: '1:188961519445:web:4af43b8c7814560b9ae1dc',
    messagingSenderId: '188961519445',
    projectId: 'farmers-b8a11',
    authDomain: 'farmers-b8a11.firebaseapp.com',
    storageBucket: 'farmers-b8a11.firebasestorage.app',
    measurementId: 'G-P4NK2ED262',
  );
}
