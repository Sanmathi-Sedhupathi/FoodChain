// firebase_options.dart.example
// Rename this file to firebase_options.dart after configuring Firebase
// Do NOT commit your actual Firebase credentials to version control.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Firebase configuration for Android and iOS platforms.
/// You must replace the placeholder values below with your actual Firebase credentials.
/// Generate this file automatically using `flutterfire configure` or fill manually.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android and iOS.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.yourcompany.yourapp',
  );
}
