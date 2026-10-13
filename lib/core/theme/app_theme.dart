import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static const _font = 'Satoshi';

  static ThemeData light() => _build(GtPalette.light, Brightness.light);
  static ThemeData dark() => _build(GtPalette.dark, Brightness.dark);

  static ThemeData _build(GtPalette p, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: GtBrand.blue,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: GtBrand.indigo,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.border,
      error: p.danger.fg,
      surfaceTint: Colors.transparent,
    );

    TextStyle s(double size, FontWeight w, Color c, [double h = 1.3]) =>
        TextStyle(fontFamily: _font, fontSize: size, fontWeight: w, color: c, height: h);

    final text = TextTheme(
      displaySmall: s(36, FontWeight.w900, p.textPrimary, 1.1),
      headlineMedium: s(28, FontWeight.w700, p.textPrimary, 1.2),
      headlineSmall: s(22, FontWeight.w700, p.textPrimary, 1.25),
      titleLarge: s(18, FontWeight.w700, p.textPrimary),
      titleMedium: s(16, FontWeight.w700, p.textPrimary),
      titleSmall: s(14, FontWeight.w700, p.textPrimary),
      bodyLarge: s(16, FontWeight.w500, p.textPrimary, 1.45),
      bodyMedium: s(14, FontWeight.w500, p.textSecondary, 1.45),
      bodySmall: s(12, FontWeight.w500, p.textMuted, 1.4),
      labelLarge: s(14, FontWeight.w700, p.textPrimary),
      labelMedium: s(12, FontWeight.w700, p.textSecondary),
      labelSmall: s(11, FontWeight.w700, p.textMuted),
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GtRadius.lg),
      side: BorderSide(color: p.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _font,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: p.page,
      canvasColor: p.page,
      dividerColor: p.border,
      extensions: [p],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: p.page,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.info.bg,
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.textMuted),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: p.primary),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: p.textMuted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.info.bg,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? p.primary : p.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.primary : p.textMuted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: GtSpace.xl),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.md)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          minimumSize: const Size(48, 44),
          side: BorderSide(color: p.border),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.md)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary, textStyle: text.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: text.bodyMedium?.copyWith(color: p.textMuted),
        labelStyle: text.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: GtSpace.lg, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtRadius.md),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtRadius.md),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GtRadius.md),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceAlt,
        side: BorderSide.none,
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.pill)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GtBrand.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: GtBrand.canvas),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.md)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        textStyle: text.bodyMedium,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: p.surface,
        headerForegroundColor: p.textPrimary,
        dividerColor: p.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.lg)),
        todayBorder: BorderSide(color: p.primary),
        dayStyle: text.bodyMedium,
        weekdayStyle: text.labelMedium,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.lg)),
        hourMinuteColor: p.surfaceAlt,
        dialBackgroundColor: p.surfaceAlt,
        dayPeriodColor: p.info.bg,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GtRadius.lg)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: GtBrand.ink,
          borderRadius: BorderRadius.circular(GtRadius.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: GtBrand.canvas),
      ),
    );
  }
}
