import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';
import 'firebase_service.dart';

class ComplaintService {
  final FirebaseService _firebaseService;

  ComplaintService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  CollectionReference<Map<String, dynamic>>? get _complaintsRef {
    try {
      if (!_firebaseService.isInitialized) {
        return null;
      }
      return _firebaseService.firestore.collection('complaints');
    } catch (_) {
      return null;
    }
  }

  /// Stream of all complaints for Admin and general tracking
  Stream<List<ComplaintModel>> getComplaintsStream() {
    try {
      final ref = _complaintsRef;
      if (ref == null) return Stream.value([]);

      return ref
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ComplaintModel.fromJson(data);
        }).toList();
      }).handleError((error) {
        if (kDebugMode) {
          print('Error in getComplaintsStream: $error');
        }
        return <ComplaintModel>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Exception in getComplaintsStream: $e');
      }
      return Stream.value([]);
    }
  }

  /// Stream of complaints assigned to an officer
  Stream<List<ComplaintModel>> getOfficerComplaintsStream({
    required String officerId,
    String? officerName,
  }) {
    try {
      final ref = _complaintsRef;
      if (ref == null) return Stream.value([]);

      return ref.snapshots().map((snapshot) {
        final all = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ComplaintModel.fromJson(data);
        }).toList();

        return all.where((c) {
          if (c.assignedOfficerId != null &&
              c.assignedOfficerId!.isNotEmpty &&
              c.assignedOfficerId == officerId) {
            return true;
          }
          if (officerName != null &&
              officerName.isNotEmpty &&
              c.assignedOfficerName != null &&
              c.assignedOfficerName!.toLowerCase() == officerName.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();
      }).handleError((error) {
        if (kDebugMode) {
          print('Error in getOfficerComplaintsStream: $error');
        }
        return <ComplaintModel>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Exception in getOfficerComplaintsStream: $e');
      }
      return Stream.value([]);
    }
  }

  /// Stream of complaints submitted by a citizen
  Stream<List<ComplaintModel>> getCitizenComplaintsStream({
    required String citizenId,
    String? citizenName,
  }) {
    try {
      final ref = _complaintsRef;
      if (ref == null) return Stream.value([]);

      return ref.snapshots().map((snapshot) {
        final all = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ComplaintModel.fromJson(data);
        }).toList();

        return all.where((c) {
          if (citizenId.isNotEmpty && c.citizenId == citizenId) {
            return true;
          }
          if (citizenName != null &&
              citizenName.isNotEmpty &&
              c.citizenName.toLowerCase() == citizenName.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();
      }).handleError((error) {
        if (kDebugMode) {
          print('Error in getCitizenComplaintsStream: $error');
        }
        return <ComplaintModel>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Exception in getCitizenComplaintsStream: $e');
      }
      return Stream.value([]);
    }
  }

  /// Uploads complaint image to Firebase Storage
  /// Path: complaints/{complaintId}/images/{timestamp}.jpg
  Future<String> uploadComplaintImage({
    required File file,
    required String complaintId,
  }) async {
    try {
      if (!_firebaseService.isInitialized) {
        return 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800';
      }

      final sanitizedId = complaintId.replaceAll(RegExp(r'[^\w\-]'), '_');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _firebaseService.storage
          .ref()
          .child('complaints')
          .child(sanitizedId)
          .child('images')
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'complaintId': complaintId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await storageRef.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading complaint image to Storage: $e');
      }
      return 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=800';
    }
  }

  /// Uploads resolution evidence from Officer to Firebase Storage
  Future<String> uploadResolutionEvidence({
    required File file,
    required String complaintId,
  }) async {
    try {
      if (!_firebaseService.isInitialized) {
        return 'https://images.unsplash.com/photo-1584467735815-f778f274e296?w=800';
      }

      final sanitizedId = complaintId.replaceAll(RegExp(r'[^\w\-]'), '_');
      final fileName = 'resolution_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _firebaseService.storage
          .ref()
          .child('complaints')
          .child(sanitizedId)
          .child('resolution')
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'complaintId': complaintId,
          'type': 'resolution_evidence',
        },
      );

      final uploadTask = await storageRef.putFile(file, metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading resolution evidence: $e');
      }
      return 'https://images.unsplash.com/photo-1584467735815-f778f274e296?w=800';
    }
  }

  /// Creates a complaint document in Firestore
  Future<bool> createComplaint(ComplaintModel complaint) async {
    try {
      final ref = _complaintsRef;
      if (ref == null) return true;

      final docRef = ref.doc(complaint.id);
      await docRef.set(complaint.toFirestore());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating complaint in Firestore: $e');
      }
      return false;
    }
  }

  /// Updates complaint status and remarks in Firestore
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    String? remarks,
    String? officerName,
    String? officerId,
    String? resolutionImageUrl,
  }) async {
    try {
      final ref = _complaintsRef;
      if (ref == null) return true;

      final docRef = ref.doc(complaintId);
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (remarks != null) updateData['officerRemarks'] = remarks;
      if (officerName != null) updateData['assignedOfficerName'] = officerName;
      if (officerId != null) updateData['assignedOfficerId'] = officerId;
      if (resolutionImageUrl != null) {
        updateData['resolutionImageUrl'] = resolutionImageUrl;
      }

      await docRef.update(updateData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating complaint status: $e');
      }
      return false;
    }
  }

  /// Assigns or reassigns an officer to a complaint
  Future<bool> assignOfficer({
    required String complaintId,
    required String officerId,
    required String officerName,
    String? department,
  }) async {
    try {
      final ref = _complaintsRef;
      if (ref == null) return true;

      final docRef = ref.doc(complaintId);
      final updateData = <String, dynamic>{
        'assignedOfficerId': officerId,
        'assignedOfficerName': officerName,
        'status': 'Assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (department != null) {
        updateData['department'] = department;
      }
      await docRef.update(updateData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning officer: $e');
      }
      return false;
    }
  }

  /// Unassigns officer from a complaint and reverts status to Submitted
  Future<bool> unassignOfficer({
    required String complaintId,
  }) async {
    try {
      final ref = _complaintsRef;
      if (ref == null) return true;

      final docRef = ref.doc(complaintId);
      final updateData = <String, dynamic>{
        'assignedOfficerId': null,
        'assignedOfficerName': null,
        'status': 'Submitted',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await docRef.update(updateData);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error unassigning officer: $e');
      }
      return false;
    }
  }

  /// Submits citizen rating and written feedback for a resolved complaint
  Future<bool> submitFeedback({
    required String complaintId,
    required int rating,
    required String feedback,
  }) async {
    try {
      final ref = _complaintsRef;
      if (ref == null) return true;

      final docRef = ref.doc(complaintId);
      await docRef.update({
        'citizenRating': rating,
        'citizenFeedback': feedback,
        'ratedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting feedback for $complaintId: $e');
      }
      return false;
    }
  }
}

