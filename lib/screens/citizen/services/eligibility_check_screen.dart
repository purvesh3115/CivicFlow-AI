import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/service_model.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/services_provider.dart';

class EligibilityCheckScreen extends StatefulWidget {
  final GovernmentServiceModel? service;

  const EligibilityCheckScreen({super.key, this.service});

  @override
  State<EligibilityCheckScreen> createState() => _EligibilityCheckScreenState();
}

class _EligibilityCheckScreenState extends State<EligibilityCheckScreen> {
  int _currentStep = 1; // 1, 2, or 3
  final ScrollController _scrollController = ScrollController();

  final List<String> _incomeTiers = [
    'tier1',
    'tier2',
    'tier3',
    'tier4',
    'tier5',
  ];

  final Map<String, String> _incomeLabels = {
    'tier1': 'Under \$25,000 (Low Income)',
    'tier2': '\$25,000 - \$49,999 (Moderate Income)',
    'tier3': '\$50,000 - \$74,999 (Middle Income)',
    'tier4': '\$75,000 - \$99,999 (Upper Middle)',
    'tier5': '\$100,000 or more',
  };

  final List<String> _employmentStatuses = [
    'Employed',
    'Self-Employed',
    'Job Seeker',
    'Student',
    'Retired',
  ];

  final List<String> _availableDocs = [
    'National ID / Aadhaar',
    'Proof of Residence / Utility Bill',
    'Income Declaration / Payslip',
    'Bank Account Details / Passbook',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 1 || step > 3) return;
    setState(() => _currentStep = step);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildStepTab(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Expanded(
      child: InkWell(
        onTap: () => _goToStep(step),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : isDone
                    ? AppColors.primary.withAlpha(25)
                    : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : isDone
                      ? AppColors.primary.withAlpha(50)
                      : AppColors.outlineVariant.withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 14,
                color: isActive
                    ? Colors.white
                    : isDone
                        ? AppColors.primary
                        : AppColors.outline,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : isDone
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = context.watch<ServicesProvider>();
    final targetService = widget.service ??
        servicesProvider.currentQuizService ??
        servicesProvider.allServices.first;
    final quizState = servicesProvider.quizState;

    double progress = _currentStep == 1
        ? 0.33
        : _currentStep == 2
            ? 0.66
            : 1.0;
    int progressPercent = (_currentStep * 33.33).round();
    if (_currentStep == 3) progressPercent = 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Eligibility Checker',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheme Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: targetService.accentColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: targetService.accentColor.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      targetService.icon,
                      size: 20,
                      color: targetService.accentColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Assessing for: ${targetService.title}',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: targetService.accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Step Selector Tabs
              Row(
                children: [
                  _buildStepTab(1, 'Basic Info'),
                  const SizedBox(width: 8),
                  _buildStepTab(2, 'Household'),
                  const SizedBox(width: 8),
                  _buildStepTab(3, 'Documents'),
                ],
              ),
              const SizedBox(height: 18),

              // Progress Bar & Step Label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStep == 1
                            ? 'Basic Information'
                            : _currentStep == 2
                                ? 'Household & Employment'
                                : 'Document Readiness',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Step $_currentStep of 3: Pre-screening questions',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$progressPercent%',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.outlineVariant.withAlpha(70),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentStep == 1
                      ? _buildStep1(servicesProvider, quizState)
                      : _currentStep == 2
                          ? _buildStep2(servicesProvider, quizState)
                          : _buildStep3(servicesProvider, quizState),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withAlpha(70),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 1)
                OutlinedButton.icon(
                  onPressed: () => _goToStep(_currentStep - 1),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < 3) {
                    _goToStep(_currentStep + 1);
                  } else {
                    // Evaluate & navigate to result
                    final result = servicesProvider.evaluateQuiz();
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eligibilityResult,
                      arguments: {
                        'result': result,
                        'service': targetService,
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentStep == 3 ? 'Evaluate Eligibility' : 'Next Step',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 1: Residency, Age, Income ---
  Widget _buildStep1(
    ServicesProvider provider,
    EligibilityQuizState quizState,
  ) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question 1: Residency
        Text(
          'Are you currently a resident of the municipality?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChoiceCard(
                title: 'Yes',
                subtitle: 'Residing > 6 months',
                icon: Icons.check_circle_outline_rounded,
                isSelected: quizState.isResident,
                onTap: () => provider.updateQuizResidency(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceCard(
                title: 'No',
                subtitle: 'Live outside city',
                icon: Icons.cancel_outlined,
                isSelected: !quizState.isResident,
                onTap: () => provider.updateQuizResidency(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Question 2: Age Group
        Text(
          'Which age group do you belong to?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AgeCard(
                title: 'Under 18',
                icon: Icons.child_care_rounded,
                isSelected: quizState.ageGroup == 'under_18',
                onTap: () => provider.updateQuizAge('under_18'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AgeCard(
                title: '18 - 64',
                icon: Icons.person_rounded,
                isSelected: quizState.ageGroup == '18_64',
                onTap: () => provider.updateQuizAge('18_64'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AgeCard(
                title: '65+',
                icon: Icons.elderly_rounded,
                isSelected: quizState.ageGroup == '65_plus',
                onTap: () => provider.updateQuizAge('65_plus'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Question 3: Income Range
        Text(
          'Estimated Annual Household Income',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the gross annual earnings of all family members.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: quizState.incomeTier,
              items: _incomeTiers.map((tier) {
                return DropdownMenuItem<String>(
                  value: tier,
                  child: Text(
                    _incomeLabels[tier] ?? tier,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  provider.updateQuizIncome(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Step 2: Household & Employment ---
  Widget _buildStep2(
    ServicesProvider provider,
    EligibilityQuizState quizState,
  ) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Household Members Stepper
        Text(
          'How many members reside in your household?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant.withAlpha(70)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.family_restroom_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${quizState.householdSize} ${quizState.householdSize == 1 ? 'Person' : 'People'}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: quizState.householdSize > 1
                        ? () => provider.updateQuizHouseholdSize(
                              quizState.householdSize - 1,
                            )
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLowest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: quizState.householdSize < 12
                        ? () => provider.updateQuizHouseholdSize(
                              quizState.householdSize + 1,
                            )
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Employment Status
        Text(
          'Current Employment Status',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _employmentStatuses.map((status) {
            final isSelected = quizState.employmentStatus == status;
            return ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.updateQuizEmployment(status);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Existing Aid Program
        Text(
          'Are you currently enrolled in other welfare assistance?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quizState.hasExistingAid
                    ? 'Yes, receiving assistance'
                    : 'No other aid programs',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: quizState.hasExistingAid,
                activeThumbColor: AppColors.primary,
                onChanged: provider.updateQuizExistingAid,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 3: Document Readiness Checklist ---
  Widget _buildStep3(
    ServicesProvider provider,
    EligibilityQuizState quizState,
  ) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Your Documents on Hand',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the credentials and documents you can readily submit for immediate verification.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ..._availableDocs.map((doc) {
          final isChecked = quizState.checkedDocuments.contains(doc);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isChecked
                  ? AppColors.primary.withAlpha(12)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isChecked
                    ? AppColors.primary
                    : AppColors.outlineVariant.withAlpha(60),
                width: isChecked ? 1.4 : 0.8,
              ),
            ),
            child: CheckboxListTile(
              value: isChecked,
              onChanged: (_) => provider.toggleQuizDocument(doc),
              title: Text(
                doc,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isChecked ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              secondary: Icon(
                Icons.folder_open_rounded,
                color: isChecked ? AppColors.primary : AppColors.outline,
              ),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        }),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  size: 22,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.outline,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
