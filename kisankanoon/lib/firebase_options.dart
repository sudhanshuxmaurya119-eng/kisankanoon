// Generated Firebase options from google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsYLlRaqta0yeMs0NqHo8QCflqYMz14io',
    appId: '1:1008016180940:android:3256cd6897929fcd2fe469',
    messagingSenderId: '1008016180940',
    projectId: 'kisankanoon',
    storageBucket: 'kisankanoon.firebasestorage.app',
  );
}
