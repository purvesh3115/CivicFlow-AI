import 'package:flutter/material.dart';

/// Represents a municipal welfare scheme or public civic service
class GovernmentServiceModel {
  final String id;
  final String title;
  final String category;
  final String department;
  final String shortDescription;
  final String fullOverview;
  final List<String> benefits;
  final List<String> eligibilityCriteria;
  final List<String> requiredDocuments;
  final String processingTime;
  final String fee;
  final bool isActive;
  final bool isBookmarked;
  final int iconCodePoint;
  final int accentColorValue;

  const GovernmentServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.shortDescription,
    required this.fullOverview,
    required this.benefits,
    required this.eligibilityCriteria,
    required this.requiredDocuments,
    required this.processingTime,
    required this.fee,
    this.isActive = true,
    this.isBookmarked = false,
    required this.iconCodePoint,
    required this.accentColorValue,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get accentColor => Color(accentColorValue);

  GovernmentServiceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? department,
    String? shortDescription,
    String? fullOverview,
    List<String>? benefits,
    List<String>? eligibilityCriteria,
    List<String>? requiredDocuments,
    String? processingTime,
    String? fee,
    bool? isActive,
    bool? isBookmarked,
    int? iconCodePoint,
    int? accentColorValue,
  }) {
    return GovernmentServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      department: department ?? this.department,
      shortDescription: shortDescription ?? this.shortDescription,
      fullOverview: fullOverview ?? this.fullOverview,
      benefits: benefits ?? this.benefits,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      processingTime: processingTime ?? this.processingTime,
      fee: fee ?? this.fee,
      isActive: isActive ?? this.isActive,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'department': department,
      'shortDescription': shortDescription,
      'fullOverview': fullOverview,
      'benefits': benefits,
      'eligibilityCriteria': eligibilityCriteria,
      'requiredDocuments': requiredDocuments,
      'processingTime': processingTime,
      'fee': fee,
      'isActive': isActive,
      'isBookmarked': isBookmarked,
      'iconCodePoint': iconCodePoint,
      'accentColorValue': accentColorValue,
    };
  }

  factory GovernmentServiceModel.fromJson(Map<String, dynamic> json) {
    return GovernmentServiceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      department: json['department'] as String,
      shortDescription: json['shortDescription'] as String,
      fullOverview: json['fullOverview'] as String,
      benefits: List<String>.from(json['benefits'] as List),
      eligibilityCriteria: List<String>.from(json['eligibilityCriteria'] as List),
      requiredDocuments: List<String>.from(json['requiredDocuments'] as List),
      processingTime: json['processingTime'] as String,
      fee: json['fee'] as String,
      isActive: json['isActive'] as bool? ?? true,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      iconCodePoint: json['iconCodePoint'] as int,
      accentColorValue: json['accentColorValue'] as int,
    );
  }
}

/// Represents an official digital certificate or document in the citizen's vault
class DocumentModel {
  final String id;
  final String title;
  final String type; // 'Identity', 'Certificate', 'Receipt', 'Permit'
  final String issueDate;
  final String expiryDate;
  final String status; // 'Verified', 'Active', 'Archived'
  final String issuingAuthority;
  final String fileSize;
  final bool isDownloaded;
  final String docNumber;
  final String qrData;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    required this.issuingAuthority,
    required this.fileSize,
    this.isDownloaded = true,
    required this.docNumber,
    required this.qrData,
  });

  DocumentModel copyWith({
    String? id,
    String? title,
    String? type,
    String? issueDate,
    String? expiryDate,
    String? status,
    String? issuingAuthority,
    String? fileSize,
    bool? isDownloaded,
    String? docNumber,
    String? qrData,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      docNumber: docNumber ?? this.docNumber,
      qrData: qrData ?? this.qrData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'status': status,
      'issuingAuthority': issuingAuthority,
      'fileSize': fileSize,
      'isDownloaded': isDownloaded,
      'docNumber': docNumber,
      'qrData': qrData,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      issueDate: json['issueDate'] as String,
      expiryDate: json['expiryDate'] as String,
      status: json['status'] as String,
      issuingAuthority: json['issuingAuthority'] as String,
      fileSize: json['fileSize'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? true,
      docNumber: json['docNumber'] as String,
      qrData: json['qrData'] as String,
    );
  }
}

/// State for multi-step eligibility assessment
class EligibilityQuizState {
  final bool isResident;
  final String ageGroup; // 'under_18', '18_64', '65_plus'
  final String incomeTier; // 'tier1', 'tier2', 'tier3', 'tier4', 'tier5'
  final int householdSize;
  final String employmentStatus; // 'Employed', 'Self-Employed', 'Student', 'Unemployed', 'Retired'
  final bool hasExistingAid;
  final List<String> checkedDocuments;

  const EligibilityQuizState({
    this.isResident = true,
    this.ageGroup = '18_64',
    this.incomeTier = 'tier2',
    this.householdSize = 3,
    this.employmentStatus = 'Employed',
    this.hasExistingAid = false,
    this.checkedDocuments = const [
      'National ID / Aadhaar',
      'Proof of Residence / Utility Bill',
      'Income Declaration / Payslip',
    ],
  });

  EligibilityQuizState copyWith({
    bool? isResident,
    String? ageGroup,
    String? incomeTier,
    int? householdSize,
    String? employmentStatus,
    bool? hasExistingAid,
    List<String>? checkedDocuments,
  }) {
    return EligibilityQuizState(
      isResident: isResident ?? this.isResident,
      ageGroup: ageGroup ?? this.ageGroup,
      incomeTier: incomeTier ?? this.incomeTier,
      householdSize: householdSize ?? this.householdSize,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      hasExistingAid: hasExistingAid ?? this.hasExistingAid,
      checkedDocuments: checkedDocuments ?? this.checkedDocuments,
    );
  }

  /// Calculates eligibility score and evaluation summary
  EligibilityResult evaluate(GovernmentServiceModel service) {
    bool eligible = true;
    final List<String> satisfiedCriteria = [];
    final List<String> pendingRequirements = [];

    // Check residency
    if (isResident) {
      satisfiedCriteria.add('Verified municipal resident (>6 months residing within ward boundaries)');
    } else {
      eligible = false;
      pendingRequirements.add('Municipality residency requirement not met (must reside within city limits)');
    }

    // Check income
    if (incomeTier == 'tier1' || incomeTier == 'tier2' || incomeTier == 'tier3') {
      satisfiedCriteria.add('Household income falls within qualifying ceiling for subsidies');
    } else {
      if (service.category == 'Housing' || service.category == 'Social Welfare') {
        eligible = false;
        pendingRequirements.add('Annual household income exceeds grant tier bracket threshold');
      } else {
        satisfiedCriteria.add('Standard tier application applicable');
      }
    }

    // Check age
    if (ageGroup == '18_64' || ageGroup == '65_plus') {
      satisfiedCriteria.add('Legal age criterion fulfilled for independent grant application');
    } else {
      satisfiedCriteria.add('Parent or legal guardian cosignatory required for under 18');
    }

    // Check documents
    if (checkedDocuments.length >= 2) {
      satisfiedCriteria.add('${checkedDocuments.length} mandatory civic proofs ready for instant upload');
    } else {
      pendingRequirements.add('At least 2 primary identification documents required');
    }

    int matchPercent = eligible ? 96 : 64;
    if (pendingRequirements.isEmpty && checkedDocuments.length >= 3) {
      matchPercent = 100;
    }

    return EligibilityResult(
      isEligible: eligible,
      matchPercentage: matchPercent,
      serviceTitle: service.title,
      satisfiedCriteria: satisfiedCriteria,
      pendingRequirements: pendingRequirements,
    );
  }
}

/// Evaluation output container
class EligibilityResult {
  final bool isEligible;
  final int matchPercentage;
  final String serviceTitle;
  final List<String> satisfiedCriteria;
  final List<String> pendingRequirements;

  const EligibilityResult({
    required this.isEligible,
    required this.matchPercentage,
    required this.serviceTitle,
    required this.satisfiedCriteria,
    required this.pendingRequirements,
  });
}
