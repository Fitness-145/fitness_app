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
    apiKey: 'AIzaSyCXi_IixJOKWm_KklWwH2hJJwq9Vmy9T4g',
    appId: '1:302187807053:web:9fe511b361d5b6802cb704',
    messagingSenderId: '302187807053',
    projectId: 'fitness-ac5a5',
    authDomain: 'fitness-ac5a5.firebaseapp.com',
    storageBucket: 'fitness-ac5a5.firebasestorage.app',
    measurementId: 'G-52E5K2RDM9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUhgD3iiSMNPW_MoDEqDX3Qs4fJUQPLXU',
    appId: '1:302187807053:android:2f6ba128a73973522cb704',
    messagingSenderId: '302187807053',
    projectId: 'fitness-ac5a5',
    storageBucket: 'fitness-ac5a5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeGkZ3NUDvRvyWnBOJms4OZpshmAziwxM',
    appId: '1:302187807053:ios:66092caddbb45d0a2cb704',
    messagingSenderId: '302187807053',
    projectId: 'fitness-ac5a5',
    storageBucket: 'fitness-ac5a5.firebasestorage.app',
    iosBundleId: 'com.example.fitnessApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeGkZ3NUDvRvyWnBOJms4OZpshmAziwxM',
    appId: '1:302187807053:ios:66092caddbb45d0a2cb704',
    messagingSenderId: '302187807053',
    projectId: 'fitness-ac5a5',
    storageBucket: 'fitness-ac5a5.firebasestorage.app',
    iosBundleId: 'com.example.fitnessApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXi_IixJOKWm_KklWwH2hJJwq9Vmy9T4g',
    appId: '1:302187807053:web:fd9d9564557196f02cb704',
    messagingSenderId: '302187807053',
    projectId: 'fitness-ac5a5',
    authDomain: 'fitness-ac5a5.firebaseapp.com',
    storageBucket: 'fitness-ac5a5.firebasestorage.app',
    measurementId: 'G-KLKM0CXDN1',
  );
}
