import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Category styles and colors for offline temple map pins
class PrecinctCategoryStyle {
  final Color bg;
  final Color border;
  final Color text;
  final IconData icon;

  const PrecinctCategoryStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.icon,
  });

  static PrecinctCategoryStyle get(String category) {
    switch (category.toLowerCase()) {
      case 'sanctum':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFFEF3C7),
          border: Color(0xFFD97706),
          text: Color(0xFF92400E),
          icon: Icons.temple_hindu_rounded,
        );
      case 'queue':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFDBEAFE),
          border: Color(0xFF2563EB),
          text: Color(0xFF1E40AF),
          icon: Icons.directions_walk_rounded,
        );
      case 'laddu':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFFEF9C3),
          border: Color(0xFFCA8A04),
          text: Color(0xFF854D0E),
          icon: Icons.cookie_rounded,
        );
      case 'footwear':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFF1F5F9),
          border: Color(0xFF64748B),
          text: Color(0xFF334155),
          icon: Icons.do_not_step_rounded,
        );
      case 'food':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFDCFCE7),
          border: Color(0xFF16A34A),
          text: Color(0xFF166534),
          icon: Icons.restaurant_rounded,
        );
      case 'medical':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFFEE2E2),
          border: Color(0xFFDC2626),
          text: Color(0xFF991B1B),
          icon: Icons.local_hospital_rounded,
        );
      case 'entry':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFE0E7FF),
          border: Color(0xFF4F46E5),
          text: Color(0xFF3730A3),
          icon: Icons.meeting_room_rounded,
        );
      case 'parking':
        return const PrecinctCategoryStyle(
          bg: Color(0xFFF3E8FF),
          border: Color(0xFF9333EA),
          text: Color(0xFF6B21A8),
          icon: Icons.local_parking_rounded,
        );
      default:
        return const PrecinctCategoryStyle(
          bg: Color(0xFFECFDF5),
          border: AppTheme.emerald,
          text: AppTheme.emerald,
          icon: Icons.location_on_rounded,
        );
    }
  }
}

/// High-Fidelity Interactive Offline Precinct Map with Smooth Gestures & Pin Transitions
class OfflinePrecinctMap extends StatefulWidget {
  final Map<String, dynamic> layoutData;

  const OfflinePrecinctMap({super.key, required this.layoutData});

  @override
  State<OfflinePrecinctMap> createState() => _OfflinePrecinctMapState();
}

class _OfflinePrecinctMapState extends State<OfflinePrecinctMap> {
  final TransformationController _transformController = TransformationController();
  Map<String, dynamic>? _selectedPin;
  bool _showLegend = false;

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleEn = widget.layoutData['titleEn'] as String? ?? 'Temple Precinct Map';
    final titleTe = widget.layoutData['titleTe'] as String? ?? '';
    final pins = (widget.layoutData['pins'] as List<dynamic>?) ?? [];
    final routePoints = (widget.layoutData['routePath'] as List<dynamic>?) ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: AppTheme.gold.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, size: 18, color: AppTheme.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleEn,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (titleTe.isNotEmpty)
                          Text(
                            titleTe,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.offline_pin_rounded, size: 12, color: AppTheme.emerald),
                        SizedBox(width: 4),
                        Text(
                          '100% OFFLINE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.emerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Map Canvas Area
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  // 1. Zoomable & Pannable Precinct Diagram
                  InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.8,
                    maxScale: 3.5,
                    boundaryMargin: const EdgeInsets.all(40),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.6,
                        child: CustomPaint(
                          painter: _PrecinctCanvasPainter(
                            pins: pins,
                            routePoints: routePoints,
                          ),
                          child: Stack(
                            children: pins.map((pin) {
                              final p = pin as Map<String, dynamic>;
                              final x = (p['svgX'] as num?)?.toDouble() ?? 250.0;
                              final y = (p['svgY'] as num?)?.toDouble() ?? 150.0;
                              final category = p['category'] as String? ?? 'info';
                              final isSelected = _selectedPin?['id'] == p['id'];
                              final style = PrecinctCategoryStyle.get(category);

                              // Normalize 500x300 canvas coordinates into proportional layout
                              return Positioned(
                                left: (x / 500.0) * 340.0,
                                top: (y / 300.0) * 210.0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPin = isSelected ? null : p;
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.35 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: style.bg,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppTheme.gold : style.border,
                                          width: isSelected ? 2.5 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: style.border.withValues(alpha: 0.35),
                                            blurRadius: isSelected ? 8 : 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        style.icon,
                                        size: isSelected ? 16 : 13,
                                        color: style.border,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Map Control Overlay Buttons
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        _buildMapButton(
                          icon: Icons.crop_free_rounded,
                          tooltip: 'Reset Zoom',
                          onTap: _resetZoom,
                        ),
                        const SizedBox(height: 6),
                        _buildMapButton(
                          icon: Icons.layers_rounded,
                          tooltip: 'Toggle Legend',
                          onTap: () => setState(() => _showLegend = !_showLegend),
                        ),
                      ],
                    ),
                  ),

                  // 3. Animated Slide-Up Detail Card on Pin Tap
                  if (_selectedPin != null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: AnimatedSlide(
                        offset: _selectedPin != null ? Offset.zero : const Offset(0, 1),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        child: _buildSelectedPinCard(_selectedPin!),
                      ),
                    ),

                  // 4. Collapsible Category Legend Overlay
                  if (_showLegend)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLegendItem('Sanctum', const Color(0xFFD97706)),
                            _buildLegendItem('Queue Line', const Color(0xFF2563EB)),
                            _buildLegendItem('Laddu Counter', const Color(0xFFCA8A04)),
                            _buildLegendItem('Footwear Stand', const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Footer Devotee Instructions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Pinch to zoom • Drag to explore • Tap any pin for details',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ),
                  Text(
                    '${pins.length} Pins',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: AppTheme.textPrimary),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPinCard(Map<String, dynamic> pin) {
    final nameEn = pin['nameEn'] as String? ?? pin['name'] as String? ?? 'Precinct Point';
    final nameTe = pin['nameTe'] as String? ?? '';
    final category = pin['category'] as String? ?? 'info';
    final descEn = pin['descEn'] as String? ?? pin['description'] as String? ?? '';
    final style = PrecinctCategoryStyle.get(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: style.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 18, color: style.border),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nameEn,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: style.text,
                        ),
                      ),
                    ),
                  ],
                ),
                if (nameTe.isNotEmpty)
                  Text(
                    nameTe,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.saffron,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (descEn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    descEn,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
            onPressed: () => setState(() => _selectedPin = null),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter rendering temple outer perimeter, sanctum chamber, and walking trail
class _PrecinctCanvasPainter extends CustomPainter {
  final List<dynamic> pins;
  final List<dynamic> routePoints;

  _PrecinctCanvasPainter({required this.pins, required this.routePoints});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Outer Precinct Boundary
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(18),
    );
    final outerPaint = Paint()
      ..color = const Color(0xFFFBF9F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(outerRect, outerPaint);

    final outerBorderPaint = Paint()
      ..color = const Color(0xFFE6DFD5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(outerRect, outerBorderPaint);

    // 2. Draw Inner Temple Sanctum Square (Ananda Nilayam / Garbhagriha Core)
    final sanctumRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.42),
        width: size.width * 0.32,
        height: size.height * 0.38,
      ),
      const Radius.circular(10),
    );
    final sanctumFill = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(sanctumRect, sanctumFill);

    final sanctumBorder = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(sanctumRect, sanctumBorder);

    // 3. Draw Connecting Queue Walkway Path
    if (routePoints.length >= 2) {
      final path = Path();
      for (int i = 0; i < routePoints.length; i++) {
        final pt = routePoints[i] as List<dynamic>;
        final px = ((pt[0] as num).toDouble() / 500.0) * size.width;
        final py = ((pt[1] as num).toDouble() / 300.0) * size.height;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }

      final routePaint = Paint()
        ..color = const Color(0xFF3B82F6).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PrecinctCanvasPainter oldDelegate) => false;
}
