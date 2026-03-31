import 'package:flutter/material.dart';

class DashboardTheme {
  static ThemeData light() {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF0F766E),
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
    );

    final scheme = base.colorScheme.copyWith(
      tertiary: const Color(0xFF0E7490),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFBFEAF5),
      onTertiaryContainer: const Color(0xFF083344),
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
        dataRowColor: WidgetStatePropertyAll(scheme.surface),
        headingTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF0F766E),
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
    );

    final scheme = base.colorScheme.copyWith(
      tertiary: const Color(0xFF67E8F9),
      onTertiary: const Color(0xFF083344),
      tertiaryContainer: const Color(0xFF164E63),
      onTertiaryContainer: const Color(0xFFBAE6FD),
    );
    
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerHighest),
        dataRowColor: WidgetStatePropertyAll(scheme.surface),
        headingTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
