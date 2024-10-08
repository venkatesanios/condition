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
    apiKey: 'AIzaSyDwd8W1csMxEOh9O9LAjHVyIjmeTRDQa3U',
    appId: '1:732330939838:web:6205477798edad42a455ef',
    messagingSenderId: '732330939838',
    projectId: 'oro-irrigation-a7ccd',
    authDomain: 'oro-irrigation-a7ccd.firebaseapp.com',
    storageBucket: 'oro-irrigation-a7ccd.appspot.com',
    measurementId: 'G-B736LFMEQ0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAC4yN-2mRrOBLE6Ph9ufmZgKO-ADHM-A',
    appId: '1:732330939838:android:291a4252c4c1a74ba455ef',
    messagingSenderId: '732330939838',
    projectId: 'oro-irrigation-a7ccd',
    storageBucket: 'oro-irrigation-a7ccd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArnaC47cL0a68Pi2p8K6vUjpoku-DWlPM',
    appId: '1:732330939838:ios:05020b4b7eb6e429a455ef',
    messagingSenderId: '732330939838',
    projectId: 'oro-irrigation-a7ccd',
    storageBucket: 'oro-irrigation-a7ccd.appspot.com',
    iosBundleId: 'com.niagaraautomations.oro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArnaC47cL0a68Pi2p8K6vUjpoku-DWlPM',
    appId: '1:732330939838:ios:38bd495fbab3a21ea455ef',
    messagingSenderId: '732330939838',
    projectId: 'oro-irrigation-a7ccd',
    storageBucket: 'oro-irrigation-a7ccd.appspot.com',
    iosBundleId: 'com.example.mobileView',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDwd8W1csMxEOh9O9LAjHVyIjmeTRDQa3U',
    appId: '1:732330939838:web:264adb66e6ae1feea455ef',
    messagingSenderId: '732330939838',
    projectId: 'oro-irrigation-a7ccd',
    authDomain: 'oro-irrigation-a7ccd.firebaseapp.com',
    storageBucket: 'oro-irrigation-a7ccd.appspot.com',
    measurementId: 'G-XWS26TW52C',
  );

}