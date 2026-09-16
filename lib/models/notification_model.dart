enum NotificationType {
  complaintStatus,
  officerRemark,
  schemeAlert,
  announcement;

  static NotificationType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'officer_remark':
        return NotificationType.officerRemark;
      case 'scheme_alert':
        return NotificationType.schemeAlert;
      case 'announcement':
        return NotificationType.announcement;
      case 'complaint_status':
      default:
        return NotificationType.complaintStatus;
    }
  }

  String toValue() {
    switch (this) {
      case NotificationType.complaintStatus:
        return 'complaint_status';
      case NotificationType.officerRemark:
        return 'officer_remark';
      case NotificationType.schemeAlert:
        return 'scheme_alert';
      case NotificationType.announcement:
        return 'announcement';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? referenceId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString()),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      isRead: json['is_read'] == true,
      referenceId: json['reference_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toValue(),
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'reference_id': referenceId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? referenceId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
