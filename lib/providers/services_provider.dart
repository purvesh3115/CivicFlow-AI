import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServicesProvider extends ChangeNotifier {
  // Category & search state
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedDocFilter = 'All';

  // Active quiz session state
  GovernmentServiceModel? _currentQuizService;
  EligibilityQuizState _quizState = const EligibilityQuizState();
  EligibilityResult? _lastResult;

  // Master mock list of government schemes
  static const List<GovernmentServiceModel> defaultServices = [
    GovernmentServiceModel(
      id: 'srv-health-universal',
      title: 'Universal Healthcare Access',
      category: 'Health',
      department: 'Health & Family Welfare Department',
      shortDescription:
          'Comprehensive municipal program ensuring every resident has access to essential medical services, preventative care, and zero-cost checkups.',
      fullOverview:
          'The Universal Healthcare Access scheme is designed to bridge the gap in medical coverage for municipal residents. By partnering with local clinics, regional hospitals, and specialized care centers, the city provides a safety net for primary, secondary, and emergency care.\n\nParticipants receive a digital municipal health card that grants access to network providers with zero out-of-pocket costs for covered preventative services and significantly reduced copays for specialized treatments.',
      benefits: [
        'Free annual wellness exams and essential disease screenings',
        'Subsidized prescription medications at partner municipal pharmacies',
        '24/7 access to telehealth nursing triage and emergency ambulance',
        'Zero out-of-pocket cost for maternity and infant vaccinations',
      ],
      eligibilityCriteria: [
        'Must be a verified resident of the municipality for > 6 months',
        'Valid Government Identification (National ID / Aadhaar / Voter ID)',
        'Household income falling within standard or subsidized civic brackets',
      ],
      requiredDocuments: [
        'National Identity Card / Aadhaar Card',
        'Proof of Current Residence (Electricity bill or Lease agreement)',
        'Recent Income Certificate or Salary Slip',
      ],
      processingTime: 'Instant upon verification (24-48 hrs)',
      fee: 'Free (Fully Funded)',
      iconCodePoint: 0xe395, // local_hospital
      accentColorValue: 0xFF004AC6,
      isActive: true,
      isBookmarked: true,
    ),
    GovernmentServiceModel(
      id: 'srv-health-grant',
      title: 'Public Health Grant',
      category: 'Health',
      department: 'Department of Public Health',
      shortDescription:
          'Financial assistance and monthly medicine stipends for low-income households requiring ongoing medical care and prescription support.',
      fullOverview:
          'The Public Health Grant provides direct financial subsidies to families experiencing chronic medical burdens. Eligible applicants receive monthly direct benefit transfers (DBT) or pharmacy discount tokens to alleviate essential medical expenses.',
      benefits: [
        'Monthly medication allowance up to \$120 or ₹3,000 equivalent',
        'Priority access to municipal diagnostic labs and imaging centers',
        'Specialized home-visit assistance for bedridden senior citizens',
      ],
      eligibilityCriteria: [
        'Resident of the municipality',
        'Annual household income under \$35,000 / ₹3,00,000',
        'Certified medical report of chronic condition from a licensed physician',
      ],
      requiredDocuments: [
        'Resident Proof Certificate',
        'Physician prescription and diagnosis history',
        'Bank Account details for Direct Benefit Transfer',
      ],
      processingTime: '3-5 Business Days',
      fee: 'Free',
      iconCodePoint: 0xe314, // health_and_safety
      accentColorValue: 0xFF004AC6,
      isActive: true,
      isBookmarked: false,
    ),
    GovernmentServiceModel(
      id: 'srv-edu-subsidy',
      title: 'Adult Education Subsidy',
      category: 'Education',
      department: 'Department of Skill Development & Higher Education',
      shortDescription:
          'Subsidized professional courses, vocational training, and continuous learning programs for adults seeking career advancement.',
      fullOverview:
          'This civic initiative equips working adults and job seekers with modern digital, technical, and vocational credentials. Tuition fees at accredited community colleges and certified polytechnic centers are covered up to 85% by the city.',
      benefits: [
        'Up to 85% course fee reimbursement for approved vocational tracks',
        'Free career counseling and resume coaching sessions',
        'Direct campus placement links with registered local employers',
      ],
      eligibilityCriteria: [
        'Resident between 18 and 55 years of age',
        'High school diploma or equivalent qualification',
        'Currently seeking employment or career transition',
      ],
      requiredDocuments: [
        'National ID / Age Proof',
        'Highest educational qualification certificate',
        'Course enrollment acceptance letter',
      ],
      processingTime: '5-7 Business Days',
      fee: 'Free Application',
      iconCodePoint: 0xe559, // school
      accentColorValue: 0xFF4059AA,
      isActive: true,
      isBookmarked: false,
    ),
    GovernmentServiceModel(
      id: 'srv-housing-relief',
      title: 'First-Time Buyer Relief',
      category: 'Housing',
      department: 'Urban Housing & Infrastructure Board',
      shortDescription:
          'Tax relief, subsidized municipal stamp duty, and down-payment assistance programs aimed at helping families purchase their first home.',
      fullOverview:
          'Designed to promote sustainable urban homeownership, the First-Time Buyer Relief scheme eliminates municipal stamp duty charges and offers interest subvention for eligible first-time homebuyers within city limits.',
      benefits: [
        '100% waiver on municipal property registration stamp duty',
        'Up to 3.5% interest rate subvention on first-time home loans',
        'Fast-track building plan sanction and property tax exemption for year 1',
      ],
      eligibilityCriteria: [
        'Applicant or spouse must not own any registered residential property',
        'Property value must adhere to municipal affordable housing caps',
        'Continuous municipality residency of at least 12 months',
      ],
      requiredDocuments: [
        'Identity & Resident proofs',
        'Agreement to Sell / Builder buyer contract',
        'No-Property Ownership Affidavit',
      ],
      processingTime: '7-10 Business Days',
      fee: '\$25 (Processing Fee)',
      iconCodePoint: 0xe55a, // home_work
      accentColorValue: 0xFF0284C7,
      isActive: true,
      isBookmarked: true,
    ),
    GovernmentServiceModel(
      id: 'srv-solar-subsidy',
      title: 'Clean Energy Solar Subsidy',
      category: 'Housing',
      department: 'Renewable Energy & Sustainability Cell',
      shortDescription:
          'Capital subsidies up to 40% for rooftop solar PV installations and bidirectional net meters for residential homes and societies.',
      fullOverview:
          'Accelerate your transition to clean energy with municipal co-funding for rooftop solar panel installation. Cut your monthly utility bills by up to 80% while feeding clean surplus energy back into the city grid.',
      benefits: [
        'Direct subsidy of 40% on system costs up to 3 kW capacity',
        'Subsidized smart net-metering setup within 14 days',
        'Guaranteed grid tariff feed-in credits for 5 consecutive years',
      ],
      eligibilityCriteria: [
        'Owner of independent residential house or designated RWA member',
        'Active domestic electricity meter in applicant name with zero dues',
        'Adequate unshaded rooftop area',
      ],
      requiredDocuments: [
        'Latest 3 months electricity bills',
        'Property tax receipt or ownership deed',
        'Rooftop layout photograph',
      ],
      processingTime: '10-14 Business Days',
      fee: 'Free',
      iconCodePoint: 0xe5da, // solar_power / energy
      accentColorValue: 0xFF0D9488,
      isActive: true,
      isBookmarked: false,
    ),
    GovernmentServiceModel(
      id: 'srv-social-pension',
      title: 'Senior Citizen Care & Pension',
      category: 'Social Welfare',
      department: 'Department of Social Welfare',
      shortDescription:
          'Direct monthly financial stipend, free city transit pass, and dedicated doorstep geriatric health support for elderly residents.',
      fullOverview:
          'A holistic civic safety net designed to honor and empower senior citizens. Provides predictable monthly financial security alongside unrestricted mobility across all civic bus, tram, and metro routes.',
      benefits: [
        'Direct monthly stipend of \$200 / ₹4,000 to senior accounts',
        'Free contactless smart mobility card for all public transit',
        'Doorstep routine medicine delivery and health checkups',
      ],
      eligibilityCriteria: [
        'Resident aged 60 years or above',
        'Resident of the city for at least 3 years',
      ],
      requiredDocuments: [
        'Age verification proof (Birth certificate, Passport, or Senior ID)',
        'Voter ID or local Resident Certificate',
        'Active bank passbook copy',
      ],
      processingTime: '3-5 Business Days',
      fee: 'Free',
      iconCodePoint: 0xe204, // diversity_3
      accentColorValue: 0xFF6A1EDB,
      isActive: true,
      isBookmarked: false,
    ),
    GovernmentServiceModel(
      id: 'srv-permit-trade',
      title: 'Commercial Trade Permit Express',
      category: 'Civic Permits',
      department: 'Licensing & Municipal Commerce Bureau',
      shortDescription:
          'One-stop digital issuance and yearly renewal for street vendors, small retail shops, cafes, and artisanal businesses.',
      fullOverview:
          'Streamline your business setup with our unified paperless single-window clearance portal. Receive authenticated digital trade certificates in PDF format equipped with verifiable civic QR codes.',
      benefits: [
        '100% paperless verification completed within 48 hours',
        'QR-code enabled certificate downloadable to digital vault',
        'Integrated waste management and municipal fire safety clearance',
      ],
      eligibilityCriteria: [
        'Commercial premise situated within approved commercial zones',
        'Standard fire safety and municipal sanitation compliance',
      ],
      requiredDocuments: [
        'Premises lease agreement or property ownership proof',
        'PAN / Business Tax Registration number',
        'Shop front photo with signage',
      ],
      processingTime: '2 Business Days',
      fee: '\$45 (Annual Permit)',
      iconCodePoint: 0xe06d, // assignment
      accentColorValue: 0xFFD97706,
      isActive: true,
      isBookmarked: false,
    ),
  ];
  final List<GovernmentServiceModel> _services = List.from(defaultServices);

  static GovernmentServiceModel get fallbackService => defaultServices.first;

  static GovernmentServiceModel? findServiceByIdOrTitle(String idOrTitle,
      [List<GovernmentServiceModel>? list]) {
    final query = idOrTitle.toLowerCase().trim();
    final source = list ?? defaultServices;
    for (final s in source) {
      if (s.id.toLowerCase() == query ||
          s.title.toLowerCase() == query ||
          s.title.toLowerCase().contains(query) ||
          query.contains(s.id.toLowerCase())) {
        return s;
      }
    }
    return null;
  }

  // Master mock list of user documents in Digital Vault
  final List<DocumentModel> _documents = [
    const DocumentModel(
      id: 'doc-001',
      title: 'National Identity Card',
      type: 'Identity',
      issueDate: '12 Jan 2020',
      expiryDate: 'Lifetime',
      status: 'Verified',
      issuingAuthority: 'Department of Civil Registry',
      fileSize: '1.4 MB',
      isDownloaded: true,
      docNumber: 'ID-9876-5432',
      qrData: 'CIVIC-AUTH:ID-9876-5432:PURVESH-SHAH:VERIFIED',
    ),
    const DocumentModel(
      id: 'doc-002',
      title: 'Resident Certificate',
      type: 'Certificate',
      issueDate: '05 Mar 2023',
      expiryDate: '04 Mar 2026',
      status: 'Active',
      issuingAuthority: 'Ward Revenue & Civic Affairs Office',
      fileSize: '890 KB',
      isDownloaded: true,
      docNumber: 'RC-2023-001',
      qrData: 'CIVIC-AUTH:RC-2023-001:WARD-04-ANAND:ACTIVE',
    ),
    const DocumentModel(
      id: 'doc-003',
      title: 'Property Tax Receipt 2023',
      type: 'Receipt',
      issueDate: '15 Apr 2023',
      expiryDate: 'N/A',
      status: 'Archived',
      issuingAuthority: 'Municipal Revenue & Taxation Board',
      fileSize: '540 KB',
      isDownloaded: true,
      docNumber: 'TX-8842-110',
      qrData: 'CIVIC-AUTH:TX-8842-110:PAID-IN-FULL:2023',
    ),
    const DocumentModel(
      id: 'doc-004',
      title: 'Municipal Water Connection',
      type: 'Certificate',
      issueDate: '18 Jan 2024',
      expiryDate: 'Lifetime',
      status: 'Active',
      issuingAuthority: 'Water Supply & Sewerage Board',
      fileSize: '1.1 MB',
      isDownloaded: true,
      docNumber: 'WC-2024-819',
      qrData: 'CIVIC-AUTH:WC-2024-819:DOMESTIC-METER:ACTIVE',
    ),
    const DocumentModel(
      id: 'doc-005',
      title: 'Commercial Trade Permit',
      type: 'Permit',
      issueDate: '10 Feb 2024',
      expiryDate: '09 Feb 2025',
      status: 'Active',
      issuingAuthority: 'City Licensing Bureau',
      fileSize: '1.2 MB',
      isDownloaded: false,
      docNumber: 'TP-2024-99B',
      qrData: 'CIVIC-AUTH:TP-2024-99B:RETAIL-CLASS-A:ACTIVE',
    ),
  ];

  // Getters
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedDocFilter => _selectedDocFilter;
  GovernmentServiceModel? get currentQuizService => _currentQuizService;
  EligibilityQuizState get quizState => _quizState;
  EligibilityResult? get lastResult => _lastResult;

  List<GovernmentServiceModel> get allServices => List.unmodifiable(_services);

  /// Filtered services according to search and category pill
  List<GovernmentServiceModel> get filteredServices {
    return _services.where((service) {
      final matchesCategory = _selectedCategory == 'All' ||
          service.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.shortDescription
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          service.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  /// Bookmarked / Saved services
  List<GovernmentServiceModel> get bookmarkedServices {
    return _services.where((service) => service.isBookmarked).toList();
  }

  /// Filtered documents according to selected filter
  List<DocumentModel> get filteredDocuments {
    if (_selectedDocFilter == 'All') {
      return List.unmodifiable(_documents);
    }
    return _documents.where((doc) {
      if (_selectedDocFilter == 'Identity & IDs') {
        return doc.type == 'Identity';
      } else if (_selectedDocFilter == 'Certificates') {
        return doc.type == 'Certificate';
      } else if (_selectedDocFilter == 'Receipts & Tax') {
        return doc.type == 'Receipt';
      } else if (_selectedDocFilter == 'Permits') {
        return doc.type == 'Permit';
      }
      return doc.type.toLowerCase() == _selectedDocFilter.toLowerCase();
    }).toList();
  }

  // --- Category and Search Modifiers ---

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDocFilter(String filter) {
    _selectedDocFilter = filter;
    notifyListeners();
  }

  void toggleBookmark(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final current = _services[index];
      _services[index] = current.copyWith(isBookmarked: !current.isBookmarked);
      notifyListeners();
    }
  }

  // --- Digital Vault Management ---

  void requestNewDocument({
    required String title,
    required String type,
    required String issuingAuthority,
  }) {
    final newId = 'doc-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final newDoc = DocumentModel(
      id: newId,
      title: title,
      type: type,
      issueDate: 'Just Now',
      expiryDate: 'Valid 3 Years',
      status: 'Active',
      issuingAuthority: issuingAuthority,
      fileSize: '1.0 MB',
      isDownloaded: true,
      docNumber: 'REQ-${DateTime.now().year}-${DateTime.now().millisecond.toString().padLeft(3, '0')}',
      qrData: 'CIVIC-AUTH:$newId:REQUESTED-ONLINE:ACTIVE',
    );

    _documents.insert(0, newDoc);
    notifyListeners();
  }

  // --- Interactive Eligibility Quiz Flow ---

  void startEligibilityQuiz(GovernmentServiceModel service) {
    _currentQuizService = service;
    _quizState = const EligibilityQuizState();
    _lastResult = null;
    notifyListeners();
  }

  void updateQuizResidency(bool isResident) {
    _quizState = _quizState.copyWith(isResident: isResident);
    notifyListeners();
  }

  void updateQuizAge(String ageGroup) {
    _quizState = _quizState.copyWith(ageGroup: ageGroup);
    notifyListeners();
  }

  void updateQuizIncome(String incomeTier) {
    _quizState = _quizState.copyWith(incomeTier: incomeTier);
    notifyListeners();
  }

  void updateQuizHouseholdSize(int size) {
    _quizState = _quizState.copyWith(householdSize: size);
    notifyListeners();
  }

  void updateQuizEmployment(String status) {
    _quizState = _quizState.copyWith(employmentStatus: status);
    notifyListeners();
  }

  void updateQuizExistingAid(bool hasAid) {
    _quizState = _quizState.copyWith(hasExistingAid: hasAid);
    notifyListeners();
  }

  void toggleQuizDocument(String docName) {
    final docs = List<String>.from(_quizState.checkedDocuments);
    if (docs.contains(docName)) {
      docs.remove(docName);
    } else {
      docs.add(docName);
    }
    _quizState = _quizState.copyWith(checkedDocuments: docs);
    notifyListeners();
  }

  EligibilityResult evaluateQuiz() {
    final service = _currentQuizService ?? _services.first;
    _lastResult = _quizState.evaluate(service);
    notifyListeners();
    return _lastResult!;
  }

  void resetQuiz() {
    _quizState = const EligibilityQuizState();
    _lastResult = null;
    notifyListeners();
  }
}
