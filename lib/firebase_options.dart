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
    apiKey: 'AIzaSyCasfKvIsUVen7jIODn0laS_xmEDPbAJjI',
    appId: '1:849777751928:web:15239bed14f20d3e203a8d',
    messagingSenderId: '849777751928',
    projectId: 'zippyit-firebase',
    authDomain: 'zippyit-firebase.firebaseapp.com',
    storageBucket: 'zippyit-firebase.firebasestorage.app',
    measurementId: 'G-GS1BNB7L6W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNYvBdZP8HZusPkQvx0mXZFg7J7c9nGFk',
    appId: '1:849777751928:android:194e22a7a3ed75d4203a8d',
    messagingSenderId: '849777751928',
    projectId: 'zippyit-firebase',
    storageBucket: 'zippyit-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCpD-_CzTqjfsAngdXRuDcB8yjyjJ1lzsA',
    appId: '1:849777751928:ios:2bd38749614f00af203a8d',
    messagingSenderId: '849777751928',
    projectId: 'zippyit-firebase',
    storageBucket: 'zippyit-firebase.firebasestorage.app',
    iosBundleId: 'com.example.zippyitapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCpD-_CzTqjfsAngdXRuDcB8yjyjJ1lzsA',
    appId: '1:849777751928:ios:2bd38749614f00af203a8d',
    messagingSenderId: '849777751928',
    projectId: 'zippyit-firebase',
    storageBucket: 'zippyit-firebase.firebasestorage.app',
    iosBundleId: 'com.example.zippyitapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCasfKvIsUVen7jIODn0laS_xmEDPbAJjI',
    appId: '1:849777751928:web:7dfea71faf099031203a8d',
    messagingSenderId: '849777751928',
    projectId: 'zippyit-firebase',
    authDomain: 'zippyit-firebase.firebaseapp.com',
    storageBucket: 'zippyit-firebase.firebasestorage.app',
    measurementId: 'G-BG4S8VEPH2',
  );
}
