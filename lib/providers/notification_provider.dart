import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  List<NotificationModel> _notifications = [];
  final Map<String, bool> _settings = {
    'push': true,
    'email': true,
    'sms': false,
    'schemes': true,
  };
  final Set<String> _locallyModifiedKeys = {};
  bool _isLoading = false;

  NotificationProvider({NotificationService? service})
      : _service = service ?? NotificationService() {
    loadNotifications();
    loadSettings();
  }

  List<NotificationModel> get notifications => _notifications;
  Map<String, bool> get settings => _settings;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _service.getNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    final loaded = await _service.getSettings();
    for (final entry in loaded.entries) {
      if (!_locallyModifiedKeys.contains(entry.key)) {
        _settings[entry.key] = entry.value;
      }
    }
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await _service.saveNotifications(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _service.saveNotifications(_notifications);
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> updateSetting(String key, bool value) async {
    _locallyModifiedKeys.add(key);
    _settings[key] = value;
    notifyListeners();
    await _service.updateSetting(key, value);
  }
}
