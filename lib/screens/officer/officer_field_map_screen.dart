import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';

class OfficerFieldMapScreen extends StatefulWidget {
  const OfficerFieldMapScreen({super.key});

  @override
  State<OfficerFieldMapScreen> createState() => _OfficerFieldMapScreenState();
}

class _OfficerFieldMapScreenState extends State<OfficerFieldMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Selected marker
  int _selectedPinIndex = 0;
  bool _isSheetVisible = true;

  final List<Map<String, dynamic>> _pins = [
    {
      'id': '#CMP-8492',
      'title': 'Pothole near University Road',
      'priority': 'HIGH PRIORITY',
      'distance': '2.4 km away',
      'reported': 'Reported 2h ago',
      'color': const Color(0xFFBA1A1A),
      'x': 0.28,
      'y': 0.32,
    },
    {
      'id': '#CMP-8493',
      'title': 'Traffic Light Malfunction',
      'priority': 'HIGH PRIORITY',
      'distance': '3.1 km away',
      'reported': 'Reported 1h ago',
      'color': const Color(0xFFB45309),
      'x': 0.72,
      'y': 0.46,
    },
    {
      'id': '#CMP-8410',
      'title': 'Water Pipe Burst',
      'priority': 'MEDIUM',
      'distance': '1.5 km away',
      'reported': 'Reported 4h ago',
      'color': const Color(0xFF006A63),
      'x': 0.40,
      'y': 0.65,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePin = _pins[_selectedPinIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Field Map',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant, height: 1),
        ),
      ),
      body: Stack(
        children: [
          // Interactive Simulated Canvas Map
          Positioned.fill(
            child: CustomPaint(
              painter: _OfficerCityMapPainter(),
            ),
          ),

          // Map Control Buttons (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControl(Icons.layers, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Satellite layer toggled')),
                  );
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.filter_list, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter: High Priority & Active Tasks')),
                  );
                }),
              ],
            ),
          ),

          // Recenter Button (Bottom Right above sheet)
          Positioned(
            bottom: _isSheetVisible ? 220 : 30,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'recenter_officer_btn',
              backgroundColor: AppColors.primary,
              onPressed: () {
                setState(() {
                  _selectedPinIndex = 0;
                  _isSheetVisible = true;
                });
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Map Pins
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Officer GPS Location (Center)
                  Positioned(
                    left: constraints.maxWidth * 0.5 - 20,
                    top: constraints.maxHeight * 0.48 - 20,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40 + (_pulseController.value * 30),
                              height: 40 + (_pulseController.value * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary
                                    .withAlpha(((1 - _pulseController.value) * 90).round()),
                              ),
                            ),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(51),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Complaint Pins
                  ..._pins.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pin = entry.value;
                    final isSelected = _selectedPinIndex == index;
                    final leftPos = constraints.maxWidth * (pin['x'] as double) - 18;
                    final topPos = constraints.maxHeight * (pin['y'] as double) - 36;

                    return Positioned(
                      left: leftPos,
                      top: topPos,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPinIndex = index;
                            _isSheetVisible = true;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: isSelected ? 42 : 34,
                                  color: pin['color'] as Color,
                                ),
                                if (pin['priority'] == 'HIGH PRIORITY')
                                  Positioned(
                                    top: -2,
                                    right: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFBA1A1A),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          // Bottom Sheet Preview (Dismissible / Expandable)
          if (_isSheetVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Header & Close
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDAD6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        activePin['priority'] as String,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF93000A),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      activePin['id'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  activePin['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                            onPressed: () => setState(() => _isSheetVisible = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Metadata row: Distance & Reported time
                      Row(
                        children: [
                          const Icon(Icons.route, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            activePin['distance'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            activePin['reported'] as String,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons: Navigate & View Details
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              key: const Key('officer_navigate_button'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Starting GPS navigation to ${activePin['title']}'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text(
                                'Navigate',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('officer_view_details_button'),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.officerComplaintDetails,
                                  arguments: activePin['id'],
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.outlineVariant),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
            ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.textPrimary, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

class _OfficerCityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Light street background
    final bgPaint = Paint()..color = const Color(0xFFF1F4F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. City block polygons
    final blockPaint = Paint()
      ..color = const Color(0xFFE5E9F0)
      ..style = PaintingStyle.fill;

    // Draw grid blocks
    const rows = 6;
    const cols = 4;
    final blockW = size.width / cols;
    final blockH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * blockW + 12,
          r * blockH + 12,
          blockW - 24,
          blockH - 24,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          blockPaint,
        );
      }
    }

    // 3. Water body (river curving on the side)
    final waterPaint = Paint()
      ..color = const Color(0xFFC7E2F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(size.width * 0.95, 0);
    riverPath.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.5,
      size.width * 0.88,
      size.height,
    );
    canvas.drawPath(riverPath, waterPaint);

    // 4. Main Arterial Roads (crisp white with outline)
    final roadCasingPaint = Paint()
      ..color = const Color(0xFFD2D6DF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    final roadSurfacePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    // Horizontal main avenue
    final hRoad = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.35);

    // Diagonal arterial
    final dRoad = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.2);

    // Vertical avenue
    final vRoad = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.45, size.height);

    for (final path in [hRoad, dRoad, vRoad]) {
      canvas.drawPath(path, roadCasingPaint);
      canvas.drawPath(path, roadSurfacePaint);
    }

    // 5. Road names
    _drawStreetName(canvas, 'University Road', Offset(size.width * 0.1, size.height * 0.33), 0);
    _drawStreetName(canvas, 'Central Ave', Offset(size.width * 0.46, size.height * 0.15), math.pi / 2);
  }

  void _drawStreetName(Canvas canvas, String name, Offset offset, double angle) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);

    final textSpan = TextSpan(
      text: name,
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
