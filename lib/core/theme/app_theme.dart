import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0AA7A5);
  static const Color background = Color(0xFFF2F5F7);
  static const Color textPrimary = Color(0xFF1F2937);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      secondary: primary,
      tertiary: const Color(0xFF0E7490),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFBFEAF5),
      onTertiaryContainer: const Color(0xFF083344),
      surface: Colors.white,
    );
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        actionsIconTheme: IconThemeData(color: scheme.onPrimary),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 48,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFD7DEE3)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      secondary: primary,
      tertiary: const Color(0xFF67E8F9),
      onTertiary: const Color(0xFF083344),
      tertiaryContainer: const Color(0xFF164E63),
      onTertiaryContainer: const Color(0xFFBAE6FD),
      surface: const Color(0xFF1E293B),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 48,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
