import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class UserService {
  final FirebaseService _firebaseService;

  UserService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  CollectionReference<Map<String, dynamic>>? get _usersRef {
    try {
      if (!_firebaseService.isInitialized) {
        return null;
      }
      return _firebaseService.firestore.collection('users');
    } catch (_) {
      return null;
    }
  }

  /// Saves or updates user document in Firestore users/{userId}
  Future<void> saveUser(UserModel user) async {
    try {
      final ref = _usersRef;
      if (ref == null) return;

      final docRef = ref.doc(user.id);
      final data = user.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();
      if (user.createdAt != null) {
        data['createdAt'] = Timestamp.fromDate(user.createdAt!);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile to Firestore: $e');
      }
    }
  }

  /// Retrieves user document from Firestore
  Future<UserModel?> getUser(String userId) async {
    try {
      final ref = _usersRef;
      if (ref == null) return null;

      final doc = await ref.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user from Firestore: $e');
      }
    }
    return null;
  }

  /// Stream of officers for Admin management and assignment
  Stream<List<UserModel>> getOfficersStream() {
    try {
      final ref = _usersRef;
      if (ref == null) return Stream.value([]);

      return ref
          .where('role', isEqualTo: 'officer')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return UserModel.fromJson(data);
        }).toList();
      }).handleError((error) {
        if (kDebugMode) {
          print('Error in getOfficersStream: $error');
        }
        return <UserModel>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Exception in getOfficersStream: $e');
      }
      return Stream.value([]);
    }
  }

  /// Fetches all active officers
  Future<List<UserModel>> getOfficers() async {
    try {
      final ref = _usersRef;
      if (ref == null) return [];

      final snapshot =
          await ref.where('role', isEqualTo: 'officer').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching officers: $e');
      }
      return [];
    }
  }
}
