import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/app_routes.dart';

class AiDocumentGuidanceScreen extends StatefulWidget {
  const AiDocumentGuidanceScreen({super.key});

  @override
  State<AiDocumentGuidanceScreen> createState() => _AiDocumentGuidanceScreenState();
}

class _AiDocumentGuidanceScreenState extends State<AiDocumentGuidanceScreen> {
  final Map<String, bool> _documentStatus = {
    'Aadhaar / National ID': true,
    'Income Certificate (< ₹3L)': true,
    'Bank Account Passbook': true,
    'Passport Size Photo': false,
  };

  final List<String> _querySuggestions = [
    'How to get an Income Certificate?',
    'What forms of Address Proof are valid?',
    'Where is the municipal verification counter?',
  ];

  String? _aiResponseText;

  void _onAskQuestion(String q) {
    setState(() {
      if (q.contains('Income')) {
        _aiResponseText =
            'Income Certificates can be issued online via the Digital Gujarat portal or at the Mamlatdar / Ward Civic Center. Required documents: Ration Card, Electricity Bill, and 3 months bank statement.';
      } else if (q.contains('Address')) {
        _aiResponseText =
            'Valid address proof includes: Aadhaar Card, Passport, Voter ID, latest Electricity / Water Utility bill in applicant name, or Registered Rental Agreement.';
      } else {
        _aiResponseText =
            'Municipal verification counters are open Mon-Fri 10:00 AM to 5:00 PM at Anand Civic Center, Station Road.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFF006A63),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Document Assistant',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High Stakes Scheme Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SCHEME PRE-SCREENING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF38BDF8),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'SLA: 24-48h',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Universal Healthcare Scheme',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pre-verification required: 3 of 4 documents validated by AI OCR scanner.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Document Checklist Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Verification Documents',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._documentStatus.entries.map((entry) {
                      final doc = entry.key;
                      final isReady = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _documentStatus[doc] = !isReady;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                isReady
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                size: 22,
                                color: isReady
                                    ? const Color(0xFF006A63)
                                    : AppColors.outline,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: isReady ? FontWeight.w600 : FontWeight.w400,
                                    color: isReady ? AppColors.textPrimary : AppColors.textSecondary,
                                    decoration: isReady ? TextDecoration.none : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isReady
                                      ? const Color(0xFFF0FDFA)
                                      : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isReady
                                        ? const Color(0xFFCCFBF1)
                                        : const Color(0xFFFFEDD5),
                                  ),
                                ),
                                child: Text(
                                  isReady ? 'READY' : 'REQUIRED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isReady
                                        ? const Color(0xFF0F766E)
                                        : const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI OCR Clarity Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006A63),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.document_scanner, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI OCR Document Readiness: 98.4%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• High-resolution clarity detected\n• Official Municipal watermark verified\n• Name & Photo matches Aadhaar registry',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Query Suggestions
              const Text(
                'Instant Answers to Common Questions:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _querySuggestions.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () => _onAskQuestion(q),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),

              if (_aiResponseText != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aiResponseText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('doc_upload_vault_btn'),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.myDocuments),
                      icon: const Icon(Icons.folder_shared_rounded, size: 16),
                      label: const Text('Open My Vault'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('doc_view_services_btn'),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.governmentServices),
                      icon: const Icon(Icons.account_balance, size: 16),
                      label: const Text('All Schemes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF006A63),
                        side: const BorderSide(color: Color(0xFF006A63)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
