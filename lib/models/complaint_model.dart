import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String department;
  final String priority;
  final String status;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> attachments;
  final String? officerRemarks;
  final String? assignedOfficerId;
  final String? assignedOfficerName;
  final String citizenId;
  final String citizenName;
  final String? resolutionImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.department,
    required this.priority,
    required this.status,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.attachments = const [],
    this.officerRemarks,
    this.assignedOfficerId,
    this.assignedOfficerName,
    this.citizenId = '',
    required this.citizenName,
    this.resolutionImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  ComplaintModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? department,
    String? priority,
    String? status,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? attachments,
    String? officerRemarks,
    String? assignedOfficerId,
    String? assignedOfficerName,
    bool clearAssignment = false,
    String? citizenId,
    String? citizenName,
    String? resolutionImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      department: department ?? this.department,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      attachments: attachments ?? this.attachments,
      officerRemarks: officerRemarks ?? this.officerRemarks,
      assignedOfficerId: clearAssignment ? null : (assignedOfficerId ?? this.assignedOfficerId),
      assignedOfficerName: clearAssignment ? null : (assignedOfficerName ?? this.assignedOfficerName),
      citizenId: citizenId ?? this.citizenId,
      citizenName: citizenName ?? this.citizenName,
      resolutionImageUrl: resolutionImageUrl ?? this.resolutionImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    final str = val.toString();
    return DateTime.tryParse(str) ?? DateTime.now();
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttachments = [];
    if (json['attachments'] != null && json['attachments'] is List) {
      parsedAttachments = List<String>.from(
        (json['attachments'] as List).map((e) => e.toString()),
      );
    } else if (json['image_url'] != null &&
        json['image_url'].toString().isNotEmpty) {
      parsedAttachments = [json['image_url'].toString()];
    } else if (json['imageUrl'] != null &&
        json['imageUrl'].toString().isNotEmpty) {
      parsedAttachments = [json['imageUrl'].toString()];
    }

    final mainImage = json['image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        (parsedAttachments.isNotEmpty ? parsedAttachments.first : null);

    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      department: json['department']?.toString() ?? 'Municipal Corp',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Submitted',
      location: json['location']?.toString() ?? 'City Center',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: mainImage,
      attachments: parsedAttachments,
      officerRemarks:
          json['officer_remarks']?.toString() ?? json['officerRemarks']?.toString(),
      assignedOfficerId:
          json['assigned_officer_id']?.toString() ?? json['assignedOfficerId']?.toString(),
      assignedOfficerName: json['assigned_officer_name']?.toString() ??
          json['assignedOfficerName']?.toString(),
      citizenId: json['citizen_id']?.toString() ?? json['citizenId']?.toString() ?? '',
      citizenName: json['citizen_name']?.toString() ?? json['citizenName']?.toString() ?? 'Citizen',
      resolutionImageUrl: json['resolution_image_url']?.toString() ??
          json['resolutionImageUrl']?.toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? _parseDateTime(json['updated_at'] ?? json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'department': department,
      'priority': priority,
      'status': status,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'attachments': attachments,
      'officer_remarks': officerRemarks,
      'assigned_officer_id': assignedOfficerId,
      'assigned_officer_name': assignedOfficerName,
      'citizen_id': citizenId,
      'citizen_name': citizenName,
      'resolution_image_url': resolutionImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'department': department,
      'priority': priority,
      'status': status,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'attachments': attachments,
      'officerRemarks': officerRemarks,
      'assignedOfficerId': assignedOfficerId,
      'assignedOfficerName': assignedOfficerName,
      'citizenId': citizenId,
      'citizenName': citizenName,
      'resolutionImageUrl': resolutionImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class OfficerTaskItem {
  final String id;
  final String title;
  final String location;
  final String time;
  bool isCompleted;

  OfficerTaskItem({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    this.isCompleted = false,
  });
}
