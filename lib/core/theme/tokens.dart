import 'package:flutter/material.dart';

/// Brand palette from the Innixx v3 Figma "Colour Palette" board
/// (file cwhKlIbRPGvUzdKDPSXpY7, node 111:1757). Typeface: Satoshi.
///
/// Widgets should not use these directly — read the theme-aware
/// [GtPalette] via `context.gt` so light/dark switch in one place.
abstract final class GtBrand {
  static const indigo = Color(0xFF14005A); // Primary brand
  static const blue = Color(0xFF0166F4); // Primary brand
  static const ink = Color(0xFF06011A); // Neutral brand (dark)
  static const canvas = Color(0xFFF7F8FC); // Neutral brand (light)
  static const sky = Color(0xFFD4F0F7); // Secondary brand
  static const mint = Color(0xFFC8F5E4); // Secondary brand
  static const coral = Color(0xFFFF7979); // Accent
  static const lemon = Color(0xFFFFEE65); // Accent
}

/// A foreground/background pair for chips, icon wells and badges.
/// Accent fills (coral, lemon) fail contrast as text, so each tone carries
/// a darker ink for text and icons.
@immutable
class GtTone {
  const GtTone(this.fg, this.bg);
  final Color fg;
  final Color bg;
}

@immutable
class GtPalette extends ThemeExtension<GtPalette> {
  const GtPalette({
    required this.page,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.heroStart,
    required this.heroEnd,
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
    required this.neutral,
    required this.violet,
  });

  final Color page;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color heroStart;
  final Color heroEnd;
  final GtTone info;
  final GtTone success;
  final GtTone warning;
  final GtTone danger;
  final GtTone neutral;
  final GtTone violet;

  static const light = GtPalette(
    page: GtBrand.canvas,
    surface: Colors.white,
    surfaceAlt: Color(0xFFF0F2F9),
    border: Color(0xFFE8E9F1),
    textPrimary: GtBrand.ink,
    textSecondary: Color(0xFF4A4760),
    textMuted: Color(0xFF85839A),
    primary: GtBrand.blue,
    onPrimary: Colors.white,
    heroStart: GtBrand.blue,
    heroEnd: GtBrand.indigo,
    info: GtTone(Color(0xFF0151C2), GtBrand.sky),
    success: GtTone(Color(0xFF0B6B4B), GtBrand.mint),
    warning: GtTone(Color(0xFF7A6200), Color(0xFFFFF7B8)),
    danger: GtTone(Color(0xFFC23A3A), Color(0xFFFFE4E4)),
    neutral: GtTone(Color(0xFF4A4760), Color(0xFFEDEEF4)),
    violet: GtTone(GtBrand.indigo, Color(0xFFE6E1F7)),
  );

  static const dark = GtPalette(
    page: GtBrand.ink,
    surface: Color(0xFF110B29),
    surfaceAlt: Color(0xFF1A1338),
    border: Color(0xFF241C47),
    textPrimary: GtBrand.canvas,
    textSecondary: Color(0xFFCAC7DC),
    textMuted: Color(0xFF8F8BA8),
    primary: Color(0xFF5C9BFF),
    onPrimary: GtBrand.ink,
    heroStart: Color(0xFF0151C2),
    heroEnd: GtBrand.indigo,
    info: GtTone(Color(0xFF9CCBF0), Color(0xFF0E2A3D)),
    success: GtTone(Color(0xFF8FE3C3), Color(0xFF0D2E25)),
    warning: GtTone(GtBrand.lemon, Color(0xFF2E2A0B)),
    danger: GtTone(Color(0xFFFF9C9C), Color(0xFF3A1416)),
    neutral: GtTone(Color(0xFFCAC7DC), Color(0xFF1F1840)),
    violet: GtTone(Color(0xFFB9A8FF), Color(0xFF231A55)),
  );

  @override
  GtPalette copyWith() => this;

  @override
  GtPalette lerp(ThemeExtension<GtPalette>? other, double t) =>
      t < 0.5 ? this : (other as GtPalette? ?? this);
}

extension GtPaletteX on BuildContext {
  GtPalette get gt => Theme.of(this).extension<GtPalette>()!;
}

/// Spacing / radius scale (Innixx cards use 12–16 px radii, flat, no shadow).
abstract final class GtSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class GtRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

/// Layout breakpoints (Material 3 window size classes).
abstract final class GtBreakpoints {
  static const medium = 600.0;
  static const expanded = 840.0;
  static const contentMax = 1200.0;
}
