import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString('saved_notifications');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => NotificationModel.fromJson(item)).toList();
      } catch (_) {}
    }

    // Default rich sample notifications matching the design
    final initialList = [
      NotificationModel(
        id: 'notif_1',
        title: 'Complaint Assigned',
        message: 'Your report "Water Supply Interruption" (#C-4920) has been assigned to Officer Sharma.',
        type: NotificationType.complaintStatus,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        referenceId: 'C-4920',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Officer Remark Added',
        message: 'Field Officer Rajesh Sharma inspected the site: "Valve repair initiated. Estimated completion 4 PM."',
        type: NotificationType.officerRemark,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        referenceId: 'C-4891',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Complaint Resolved',
        message: 'Your complaint "Streetlight not working" (#C-4810) has been marked Resolved. Tap to review photo proof.',
        type: NotificationType.complaintStatus,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        referenceId: 'C-4810',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'New Municipal Scheme',
        message: 'Apply for the Clean Solar Rooftop Subsidy 2026. Check eligibility and required documents now.',
        type: NotificationType.schemeAlert,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        referenceId: 'SCH-SOLAR-01',
      ),
    ];

    await saveNotifications(initialList);
    return initialList;
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString('saved_notifications', jsonStr);
  }

  Future<Map<String, bool>> getSettings() async {
    final prefs = await _getPrefs();
    return {
      'push': prefs.getBool('notif_push') ?? true,
      'email': prefs.getBool('notif_email') ?? true,
      'sms': prefs.getBool('notif_sms') ?? false,
      'schemes': prefs.getBool('notif_schemes') ?? true,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool('notif_$key', value);
  }
}
