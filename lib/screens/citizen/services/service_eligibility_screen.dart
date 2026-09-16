import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/service_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/services_provider.dart';

class ServiceEligibilityScreen extends StatefulWidget {
  final GovernmentServiceModel service;

  const ServiceEligibilityScreen({super.key, required this.service});

  @override
  State<ServiceEligibilityScreen> createState() => _ServiceEligibilityScreenState();
}

class _ServiceEligibilityScreenState extends State<ServiceEligibilityScreen> {
  final Set<String> _checkedDocs = {};
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Default check first doc
    if (widget.service.requiredDocuments.isNotEmpty) {
      _checkedDocs.add(widget.service.requiredDocuments.first);
    }
  }

  void _onApplyNow() {
    setState(() => _isApplying = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isApplying = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Application Initiated',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are applying for:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.service.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF0F766E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ready documents: ${_checkedDocs.length} of ${widget.service.requiredDocuments.length} checked.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF0F766E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your citizen profile data and verified documents will be automatically linked with this application.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Application for "${widget.service.title}" submitted successfully!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Proceed to Submit'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final totalDocs = s.requiredDocuments.length;
    final checkedCount = _checkedDocs.length;
    final docsReady = checkedCount >= totalDocs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Eligibility Requirements',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheme Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: s.accentColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s.icon, size: 28, color: s.accentColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.accentColor.withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: s.accentColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.department,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Overview Tagline
              Text(
                'Comprehensive Criteria Guidelines',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please verify all the eligibility dimensions below before filing an official government application.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Criteria Dimension 1: Who Can Apply
              _buildCriteriaBentoCard(
                icon: Icons.people_outline_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'Who Can Apply',
                badgeText: 'BENEFICIARIES',
                badgeColor: const Color(0xFFE0F2FE),
                badgeTextColor: const Color(0xFF0369A1),
                details: _getWhoCanApply(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 2: Age Requirements
              _buildCriteriaBentoCard(
                icon: Icons.cake_outlined,
                iconColor: const Color(0xFF7C3AED),
                title: 'Age Requirements',
                badgeText: 'AGE LIMITS',
                badgeColor: const Color(0xFFEDE9FE),
                badgeTextColor: const Color(0xFF6D28D9),
                details: _getAgeRequirements(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 3: Residency Requirements
              _buildCriteriaBentoCard(
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFF059669),
                title: 'Residency Requirements',
                badgeText: 'LOCAL DOMICILE',
                badgeColor: const Color(0xFFD1FAE5),
                badgeTextColor: const Color(0xFF047857),
                details: _getResidencyRequirements(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 4: Income Criteria
              _buildCriteriaBentoCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'Income Criteria',
                badgeText: 'ANNUAL CEILING',
                badgeColor: const Color(0xFFFEF3C7),
                badgeTextColor: const Color(0xFFB45309),
                details: _getIncomeCriteria(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 5: Category / Caste / Community
              _buildCriteriaBentoCard(
                icon: Icons.diversity_3_outlined,
                iconColor: const Color(0xFFE11D48),
                title: 'Category & Community Criteria',
                badgeText: 'AFFIRMATIVE ACTION',
                badgeColor: const Color(0xFFFFE4E6),
                badgeTextColor: const Color(0xFFBE123C),
                details: _getCategoryCriteria(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 6: Employment / Student Conditions
              _buildCriteriaBentoCard(
                icon: Icons.work_outline_rounded,
                iconColor: const Color(0xFF4F46E5),
                title: 'Employment & Student Status',
                badgeText: 'OCCUPATION',
                badgeColor: const Color(0xFFE0E7FF),
                badgeTextColor: const Color(0xFF4338CA),
                details: _getEmploymentConditions(s),
              ),
              const SizedBox(height: 12),

              // Criteria Dimension 7: Other Mandatory Conditions
              _buildCriteriaBentoCard(
                icon: Icons.verified_user_outlined,
                iconColor: const Color(0xFF0F766E),
                title: 'Other Conditions & Direct Transfer',
                badgeText: 'AADHAAR & DBT',
                badgeColor: const Color(0xFFCCFBF1),
                badgeTextColor: const Color(0xFF0F766E),
                details: [
                  'Must possess a valid National ID / Aadhaar card linked with active phone number.',
                  'Operational bank account with active Direct Benefit Transfer (DBT) linking.',
                  'No outstanding municipal property tax or utility recovery defaults.',
                  'Valid email address and mobile phone for receiving SMS OTP notifications.',
                ],
              ),
              const SizedBox(height: 18),

              // Required Documents Checklist Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: docsReady ? AppColors.success.withAlpha(80) : AppColors.outlineVariant,
                    width: docsReady ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fact_check_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Required Documents Checklist',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: docsReady ? AppColors.successContainer : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$checkedCount / $totalDocs Ready',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: docsReady ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Check the documents you currently hold ready in digital or physical format:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ...s.requiredDocuments.map((doc) {
                      final isChecked = _checkedDocs.contains(doc);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _checkedDocs.remove(doc);
                            } else {
                              _checkedDocs.add(doc);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isChecked ? AppColors.primary.withAlpha(10) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isChecked ? AppColors.primary : AppColors.outlineVariant,
                              width: isChecked ? 1.3 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isChecked ? AppColors.primary : AppColors.outline,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                                    color: isChecked ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.file_present_rounded, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom bar
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 0.8),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Check Documents Vault Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.myDocuments);
                },
                icon: const Icon(Icons.folder_shared_outlined, size: 18),
                label: const Text('My Vault'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),

              // Interactive Quiz Shortcut
              OutlinedButton.icon(
                onPressed: () {
                  context.read<ServicesProvider>().startEligibilityQuiz(s);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.eligibilityCheck,
                    arguments: s,
                  );
                },
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: const Text('Run Quiz'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),

              // Primary Apply Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isApplying ? null : _onApplyNow,
                  icon: _isApplying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  label: Text(
                    _isApplying ? 'Processing...' : 'Apply Now',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaBentoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required List<String> details,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...details.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getWhoCanApply(GovernmentServiceModel s) {
    if (s.category == 'Health') {
      return [
        'All registered municipal residents requiring healthcare or medical subsidies.',
        'Families seeking preventative checkups, diagnostics, and prescription assistance.',
        'Senior citizens, expectant mothers, and dependent infants under primary care.',
      ];
    } else if (s.category == 'Education') {
      return [
        'Adult learners and working professionals aiming for accredited upskilling.',
        'Job seekers and college graduates seeking vocational certifications.',
        'High school diploma holders applying to municipal polytechnics.',
      ];
    } else if (s.category == 'Housing') {
      return [
        'First-time prospective residential property purchasers.',
        'Registered homeowners applying for rooftop green solar subsidies.',
        'Urban families residing in authorized residential zones within municipal limits.',
      ];
    } else {
      return [
        'Individual citizens possessing legal residential status.',
        'Households registered under the municipal civic register.',
        'Self-employed workers or recognized civic business owners.',
      ];
    }
  }

  List<String> _getAgeRequirements(GovernmentServiceModel s) {
    if (s.category == 'Education') {
      return [
        'Minimum Age: 18 years completed at the time of course enrollment.',
        'Maximum Age: 55 years for vocational scholarship grants.',
      ];
    } else if (s.category == 'Housing') {
      return [
        'Primary applicant must be at least 21 years of age.',
        'Co-applicant spouse / family member must be at least 18 years of age.',
      ];
    } else {
      return [
        'Open to all age groups (Infants to Senior Citizens).',
        'Applicants under 18 require endorsement from a parent or legal guardian.',
        'Senior citizens (60+) receive fast-track verification priority.',
      ];
    }
  }

  List<String> _getResidencyRequirements(GovernmentServiceModel s) {
    return [
      'Continuous residence within the municipal corporation boundaries for at least 6 months.',
      'Verified local address proof (Electricity/Water utility bill or registered lease agreement).',
      'Listing on the municipal electoral ward roll or civil registry database.',
    ];
  }

  List<String> _getIncomeCriteria(GovernmentServiceModel s) {
    if (s.category == 'Health' && s.id.contains('grant')) {
      return [
        'Low-to-Moderate Income bracket: Household income under \$35,000 / ₹3,00,000 annually.',
        'Below Poverty Line (BPL) cardholders receive 100% full coverage.',
      ];
    } else if (s.category == 'Housing') {
      return [
        'Economically Weaker Section (EWS) or Low Income Group (LIG) for maximum stamp duty waiver.',
        'Middle Income Group (MIG) qualifying for partial interest rate subvention.',
      ];
    } else {
      return [
        'Universal Coverage Scheme: No upper income ceiling for standard tier benefits.',
        'Subsidized fee tiers available upon presentation of verified income certificate.',
      ];
    }
  }

  List<String> _getCategoryCriteria(GovernmentServiceModel s) {
    return [
      'Open to all social categories and community groups without discrimination.',
      'Special 10% fee waiver & priority processing for Scheduled Castes (SC) and Scheduled Tribes (ST).',
      'Affirmative quota provisions for Differently-Abled citizens (PwD) and Women-headed households.',
    ];
  }

  List<String> _getEmploymentConditions(GovernmentServiceModel s) {
    if (s.category == 'Education') {
      return [
        'Open to active job seekers, unemployed adults, and workers seeking technical upskilling.',
        'Both formal salaried employees and unorganized informal workers eligible.',
      ];
    } else if (s.category == 'Housing') {
      return [
        'Salaried employees with minimum 1 year continuous employment history.',
        'Self-employed professionals with filed Income Tax Returns (ITR) for last 2 assessment years.',
      ];
    } else {
      return [
        'No restriction on employment status.',
        'Applicable to salaried, self-employed, daily-wage earners, students, homemakers, and retirees.',
      ];
    }
  }
}
