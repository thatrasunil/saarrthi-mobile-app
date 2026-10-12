import 'package:flutter/material.dart';

/// Reusable, high-fidelity Saarthi Pilgrim Logo Widget
/// Renders the official location-pin rising sun & winding mountain path logo
/// with optional drop shadow, custom sizing, and smooth rounded presentation.
class SaarthiLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final double borderRadius;
  final VoidCallback? onTap;

  const SaarthiLogo({
    super.key,
    this.size = 36.0,
    this.showShadow = false,
    this.borderRadius = 8.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.asset(
      'assets/icons/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE9801D), Color(0xFF0F5132)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.explore_rounded,
            size: size * 0.55,
            color: Colors.white,
          ),
        );
      },
    );

    if (showShadow) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: size * 0.25,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: imageWidget,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
