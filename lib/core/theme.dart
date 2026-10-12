import 'package:flutter/material.dart';

class AppTheme {
  // Sacred Pilgrim Palette
  static const Color canvasBg = Color(0xFFFAF8F5);
  static const Color emerald = Color(0xFF0F5132);
  static const Color emeraldLight = Color(0xFFF0FDF4);
  static const Color saffron = Color(0xFFE9801D);
  static const Color saffronLight = Color(0xFFFFF7ED);
  static const Color gold = Color(0xFFC89B3C);
  static const Color goldLight = Color(0xFFFEF9C3);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1ECE5);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderSubtle = Color(0xFFECE9E3);

  // Status Colors for Live Queue
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusGreenBg = Color(0xFFDCFCE7);
  static const Color statusAmber = Color(0xFFD97706);
  static const Color statusAmberBg = Color(0xFFFEF3C7);
  static const Color statusRed = Color(0xFFDC2626);
  static const Color statusRedBg = Color(0xFFFEE2E2);

  // Responsive, Clean Typography Styles
  static const TextStyle brandTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: emerald,
    letterSpacing: -0.5,
  );

  static const TextStyle screenHeader = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: textMuted,
    height: 1.35,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvasBg,
      colorScheme: const ColorScheme.light(
        primary: emerald,
        secondary: saffron,
        tertiary: gold,
        surface: surfaceCard,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvasBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
    );
  }
}
