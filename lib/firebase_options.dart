import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Generated configuration for project citizen-connect-57db0.
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
        return ios;
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
    apiKey: 'AIzaSyBfx8NR4GfnK-EY8d-fCd-TK0b6SBhZ9ns',
    appId: '1:492981225561:web:c8cd1815737f993347c948',
    messagingSenderId: '492981225561',
    projectId: 'citizen-connect-57db0',
    authDomain: 'citizen-connect-57db0.firebaseapp.com',
    storageBucket: 'citizen-connect-57db0.firebasestorage.app',
    measurementId: 'G-QTGW7RSZ67',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6dnrYsqUMDh_ohs40DJSyWGoMaKWb0TI',
    appId: '1:492981225561:android:0edf3027c4d174c947c948',
    messagingSenderId: '492981225561',
    projectId: 'citizen-connect-57db0',
    storageBucket: 'citizen-connect-57db0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBfx8NR4GfnK-EY8d-fCd-TK0b6SBhZ9ns',
    appId: '1:492981225561:ios:75bb0b081dc8384047c948',
    messagingSenderId: '492981225561',
    projectId: 'citizen-connect-57db0',
    storageBucket: 'citizen-connect-57db0.firebasestorage.app',
    iosBundleId: 'com.citizenconnect.citizenConnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBfx8NR4GfnK-EY8d-fCd-TK0b6SBhZ9ns',
    appId: '1:492981225561:web:a2923984d307566447c948',
    messagingSenderId: '492981225561',
    projectId: 'citizen-connect-57db0',
    authDomain: 'citizen-connect-57db0.firebaseapp.com',
    storageBucket: 'citizen-connect-57db0.firebasestorage.app',
  );
}
