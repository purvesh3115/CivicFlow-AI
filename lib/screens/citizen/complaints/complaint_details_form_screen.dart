import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/primary_button.dart';

class ComplaintDetailsFormScreen extends StatefulWidget {
  const ComplaintDetailsFormScreen({super.key});

  @override
  State<ComplaintDetailsFormScreen> createState() =>
      _ComplaintDetailsFormScreenState();
}

class _ComplaintDetailsFormScreenState
    extends State<ComplaintDetailsFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  String _selectedPriority = 'High';
  bool _isUsingGps = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ComplaintProvider>();
    _titleController = TextEditingController(text: provider.draftTitle);
    _descriptionController =
        TextEditingController(text: provider.draftDescription);
    _locationController = TextEditingController(text: provider.draftLocation);
    _selectedPriority = provider.draftPriority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onUseCurrentLocation() {
    setState(() {
      _isUsingGps = true;
      _locationController.text = 'Main St & Elm St, Northbound lane, Anand';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('GPS location acquired: Anand, Gujarat'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ComplaintProvider>().setDraftDetails(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            location: _locationController.text.trim(),
            latitude: 22.5645,
            longitude: 72.9289,
          );
      Navigator.pushNamed(context, AppRoutes.uploadEvidence);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'CitizenConnect',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Bar: Step 2 of 4 (50%)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STEP 2 OF 4',
                            style: AppTypography.labelSmall.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'DETAILS',
                            style: AppTypography.labelSmall.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.50,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Selected Category Chip Banner
                      if (provider.draftCategory.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryContainer.withAlpha(60),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Category: ${provider.draftCategory}',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Section 1: What Happened?
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withAlpha(60),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.edit_document,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'What happened?',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Complaint Title
                            Row(
                              children: [
                                Text(
                                  'Complaint Title',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _titleController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Complaint Title is mandatory. Please enter a title';
                                }
                                if (val.trim().length < 3) {
                                  return 'Title must be at least 3 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g. Pothole on Main St.',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.outline,
                                ),
                                helperText: 'Keep it brief and descriptive.',
                                helperStyle: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Row(
                              children: [
                                Text(
                                  'Description',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Description is mandatory. Please describe the issue';
                                }
                                if (val.trim().length < 5) {
                                  return 'Please provide at least 5 characters of detail';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Provide more details about the issue (e.g. size, danger, duration)...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.outline,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Priority Selector
                            Row(
                              children: [
                                Text(
                                  'Priority Level',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['Low', 'Medium', 'High', 'Urgent']
                                  .map((p) {
                                final isSelected = _selectedPriority == p;
                                Color pColor;
                                switch (p) {
                                  case 'Urgent':
                                    pColor = AppColors.error;
                                    break;
                                  case 'High':
                                    pColor = Colors.orange.shade800;
                                    break;
                                  case 'Medium':
                                    pColor = AppColors.secondary;
                                    break;
                                  default:
                                    pColor = AppColors.outline;
                                }

                                return ChoiceChip(
                                  label: Text(p),
                                  selected: isSelected,
                                  onSelected: (sel) {
                                    if (sel) setState(() => _selectedPriority = p);
                                  },
                                  selectedColor: pColor.withAlpha(30),
                                  backgroundColor: AppColors.surface,
                                  labelStyle: TextStyle(
                                    color: isSelected ? pColor : AppColors.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? pColor
                                        : AppColors.outlineVariant.withAlpha(80),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Where did it happen?
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withAlpha(60),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.pin_drop_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Where did it happen?',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Use Current Location Option Button
                            InkWell(
                              onTap: _onUseCurrentLocation,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _isUsingGps
                                      ? AppColors.primaryContainer.withAlpha(20)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isUsingGps
                                        ? AppColors.primary
                                        : AppColors.outlineVariant.withAlpha(80),
                                    width: _isUsingGps ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Use Current Location',
                                            style: AppTypography.labelLarge.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            _isUsingGps
                                                ? 'GPS Locked: Station Road, Anand'
                                                : 'Requires GPS access',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: _isUsingGps
                                                  ? AppColors.primary
                                                  : AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isUsingGps)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'OR',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Search Location Field
                            Row(
                              children: [
                                Text(
                                  'Location Address',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _locationController,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Location address is mandatory. Please enter address or tap GPS';
                                }
                                if (val.trim().length < 4) {
                                  return 'Please provide a valid location address';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for an address or landmark...',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.outline,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.outline,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withAlpha(80),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Stylized Mini Map Container
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EEF8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withAlpha(80),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Map Background Grid Lines simulation
                                  CustomPaint(
                                    size: const Size(double.infinity, 160),
                                    painter: _MiniMapPainter(),
                                  ),
                                  // Center Pin Overlay
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withAlpha(90),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(160),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Selected Location',
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Map helper pill
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(220),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.outlineVariant
                                              .withAlpha(60),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.touch_app_rounded,
                                            size: 12,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tap map to refine location',
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                              fontSize: 10,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withAlpha(60),
                    width: 0.8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 160,
                      child: PrimaryButton(
                        text: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _onContinue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = const Color(0xFFD6E3F8)
      ..style = PaintingStyle.fill;

    // Draw blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 15, size.width * 0.4, 50),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 15, size.width * 0.38, 50),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 85, size.width * 0.4, 60),
        const Radius.circular(6),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 85, size.width * 0.38, 60),
        const Radius.circular(6),
      ),
      blockPaint,
    );

    // Draw roads
    final path = Path();
    // Vertical road
    path.moveTo(size.width * 0.48, 0);
    path.lineTo(size.width * 0.48, size.height);
    // Horizontal road
    path.moveTo(0, 72);
    path.lineTo(size.width, 72);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
