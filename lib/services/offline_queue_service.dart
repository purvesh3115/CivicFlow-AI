import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint_model.dart';
import 'complaint_service.dart';

class OfflineQueueService {
  static const String _queueKey = 'citizen_connect_offline_complaints_queue';
  final SharedPreferences? _prefs;

  OfflineQueueService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs;
    return await SharedPreferences.getInstance();
  }

  /// Adds a complaint to the persistent offline queue
  Future<bool> queueComplaint(ComplaintModel complaint) async {
    try {
      final prefs = await _getPrefs();
      final List<String> rawList = prefs.getStringList(_queueKey) ?? [];

      // Avoid duplicates
      rawList.removeWhere((item) {
        try {
          final Map<String, dynamic> data = jsonDecode(item);
          return data['id']?.toString().toLowerCase() ==
              complaint.id.toLowerCase();
        } catch (_) {
          return false;
        }
      });

      final offlineData = complaint.copyWith(status: 'Queued Offline');
      rawList.add(jsonEncode(offlineData.toJson()));

      await prefs.setStringList(_queueKey, rawList);
      if (kDebugMode) {
        print('Complaint ${complaint.id} queued offline. Total queued: ${rawList.length}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error queueing complaint offline: $e');
      }
      return false;
    }
  }

  /// Retrieves all complaints currently stored in the offline queue
  Future<List<ComplaintModel>> getQueuedComplaints() async {
    try {
      final prefs = await _getPrefs();
      final List<String> rawList = prefs.getStringList(_queueKey) ?? [];
      final List<ComplaintModel> result = [];

      for (final raw in rawList) {
        try {
          final Map<String, dynamic> data = jsonDecode(raw);
          result.add(ComplaintModel.fromJson(data));
        } catch (err) {
          if (kDebugMode) {
            print('Corrupted offline complaint JSON skipped: $err');
          }
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading offline complaints: $e');
      }
      return [];
    }
  }

  /// Removes a single complaint from the offline queue
  Future<bool> removeQueuedComplaint(String complaintId) async {
    try {
      final prefs = await _getPrefs();
      final List<String> rawList = prefs.getStringList(_queueKey) ?? [];

      rawList.removeWhere((item) {
        try {
          final Map<String, dynamic> data = jsonDecode(item);
          return data['id']?.toString().toLowerCase() ==
              complaintId.toLowerCase();
        } catch (_) {
          return false;
        }
      });

      await prefs.setStringList(_queueKey, rawList);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing queued complaint $complaintId: $e');
      }
      return false;
    }
  }

  /// Clears all items in the offline queue
  Future<void> clearQueue() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_queueKey);
    } catch (_) {}
  }

  /// Returns count of pending offline complaints
  Future<int> getQueueCount() async {
    try {
      final prefs = await _getPrefs();
      final List<String>? rawList = prefs.getStringList(_queueKey);
      return rawList?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Synchronizes all queued complaints to Firebase Firestore & Storage
  /// Returns the number of successfully synced complaints.
  Future<int> syncQueue({required ComplaintService complaintService}) async {
    final queued = await getQueuedComplaints();
    if (queued.isEmpty) return 0;

    int syncedCount = 0;

    for (final complaint in queued) {
      try {
        String? uploadedImageUrl = complaint.imageUrl;
        final List<String> uploadedAttachments = [];

        // Check if there is a local photo attachment that needs uploading
        if (complaint.imageUrl != null &&
            complaint.imageUrl!.isNotEmpty &&
            !complaint.imageUrl!.startsWith('http') &&
            !kIsWeb) {
          final localFile = File(complaint.imageUrl!);
          if (await localFile.exists()) {
            uploadedImageUrl = await complaintService.uploadComplaintImage(
              file: localFile,
              complaintId: complaint.id,
            );
          }
        }

        for (final att in complaint.attachments) {
          if (!att.startsWith('http') && !kIsWeb) {
            final f = File(att);
            if (await f.exists()) {
              final remoteUrl = await complaintService.uploadComplaintImage(
                file: f,
                complaintId: complaint.id,
              );
              uploadedAttachments.add(remoteUrl);
            } else {
              uploadedAttachments.add(att);
            }
          } else {
            uploadedAttachments.add(att);
          }
        }

        // Prepare finalized complaint model with Submitted status
        final syncedComplaint = complaint.copyWith(
          imageUrl: uploadedImageUrl,
          attachments: uploadedAttachments.isNotEmpty
              ? uploadedAttachments
              : (uploadedImageUrl != null ? [uploadedImageUrl] : []),
          status: 'Submitted',
          updatedAt: DateTime.now(),
        );

        final success =
            await complaintService.createComplaint(syncedComplaint);

        if (success) {
          await removeQueuedComplaint(complaint.id);
          syncedCount++;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to sync complaint ${complaint.id}: $e');
        }
      }
    }

    return syncedCount;
  }
}
