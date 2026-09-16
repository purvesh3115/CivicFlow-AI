import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized || Firebase.apps.isNotEmpty;

  FirebaseAuth get auth {
    return FirebaseAuth.instance;
  }

  FirebaseFirestore get firestore {
    return FirebaseFirestore.instance;
  }

  FirebaseStorage get storage {
    return FirebaseStorage.instance;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      if (kDebugMode) {
        print('Firebase initialized successfully for citizen-connect-57db0');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization warning: $e');
      }
      // If already initialized in another isolate or test runner
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
      }
    }
  }
}
