// Generated Firebase options from Firebase project configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBva5B1IGP2RlbxFnQO-yXLd4tdrRPGmrs',
    appId: '1:1008016180940:web:53dae383e452ca482fe469',
    messagingSenderId: '1008016180940',
    projectId: 'kisankanoon',
    authDomain: 'kisankanoon.firebaseapp.com',
    storageBucket: 'kisankanoon.firebasestorage.app',
    measurementId: 'G-HVHD7ZGKFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsYLlRaqta0yeMs0NqHo8QCflqYMz14io',
    appId: '1:1008016180940:android:3256cd6897929fcd2fe469',
    messagingSenderId: '1008016180940',
    projectId: 'kisankanoon',
    storageBucket: 'kisankanoon.firebasestorage.app',
  );
}
