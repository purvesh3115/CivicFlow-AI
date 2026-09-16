import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import 'primary_button.dart';

class CitizenFeedbackModal extends StatefulWidget {
  final ComplaintModel complaint;
  final ComplaintProvider? complaintProvider;

  const CitizenFeedbackModal({
    super.key,
    required this.complaint,
    this.complaintProvider,
  });

  static Future<bool?> show(
    BuildContext context,
    ComplaintModel complaint, {
    ComplaintProvider? complaintProvider,
  }) {
    final effectiveProvider =
        complaintProvider ?? _tryReadProvider<ComplaintProvider>(context);

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final modal = CitizenFeedbackModal(
          complaint: complaint,
          complaintProvider: effectiveProvider,
        );
        if (effectiveProvider != null) {
          return ChangeNotifierProvider<ComplaintProvider>.value(
            value: effectiveProvider,
            child: modal,
          );
        }
        return modal;
      },
    );
  }

  static T? _tryReadProvider<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  @override
  State<CitizenFeedbackModal> createState() => _CitizenFeedbackModalState();
}

class _CitizenFeedbackModalState extends State<CitizenFeedbackModal> {
  int _rating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  final List<String> _quickTags = [
    'Fast Response',
    'Clean Work',
    'Polite Officer',
    'High Quality',
    'Fixed on Time',
    'Clear Communication',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor - Needs immediate attention';
      case 2:
        return 'Fair - Resolution had shortcomings';
      case 3:
        return 'Good - Satisfactorily completed';
      case 4:
        return 'Very Good - Prompt & efficient service';
      case 5:
        return 'Excellent - Outstanding civic resolution!';
      default:
        return 'Tap a star to rate';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFEAB308);
      case 4:
        return const Color(0xFF10B981);
      case 5:
        return const Color(0xFFF59E0B);
      default:
        return AppColors.outline;
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    // Combine tags and text comments
    String comments = _feedbackController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tagsStr = _selectedTags.join(', ');
      comments = comments.isNotEmpty
          ? '[$tagsStr] $comments'
          : 'Highlighted qualities: $tagsStr.';
    }

    if (comments.isEmpty) {
      comments = 'Resolution rated $_rating out of 5 stars.';
    }

    ComplaintProvider? complaintProvider = widget.complaintProvider;
    if (complaintProvider == null) {
      try {
        complaintProvider = context.read<ComplaintProvider>();
      } catch (_) {}
    }

    final success = complaintProvider != null
        ? await complaintProvider.submitComplaintFeedback(
            complaintId: widget.complaint.id,
            rating: _rating,
            feedback: comments,
          )
        : true;

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thank you for rating! Resolution feedback submitted for ${widget.complaint.id}.',
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit feedback. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title and Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD97706),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate Resolution Quality',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Complaint ${widget.complaint.id} • ${widget.complaint.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.outline,
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Officer Info Chip if assigned
              if (widget.complaint.assignedOfficerName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.engineering_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resolved by: ${widget.complaint.assignedOfficerName}',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Star Rating Row
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isFilled = starIndex <= _rating;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _rating = starIndex);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: isFilled
                              ? const Color(0xFFF59E0B)
                              : AppColors.outlineVariant,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),

              // Rating label text
              Center(
                child: Text(
                  _getRatingLabel(_rating),
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getRatingColor(_rating),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Quick tags
              Text(
                'What went well?',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _quickTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withAlpha(80),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Written feedback text field
              Text(
                'Detailed Feedback (Optional)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText:
                      'Share details about the work done, cleanliness, or officer response...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.outline,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              PrimaryButton(
                text: 'Submit Feedback',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Maybe Later',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
