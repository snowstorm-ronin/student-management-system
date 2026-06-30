import 'package:firebase_core/firebase_core.dart';

// Rename this file to firebase_options.dart and fill in your Firebase config
// Get these values from Firebase Console → Project Settings → Your Apps → Web App

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      authDomain: 'YOUR_AUTH_DOMAIN',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    );
  }
}