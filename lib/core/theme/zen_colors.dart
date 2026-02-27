import 'package:flutter/painting.dart';

/// Color tokens for Zen Journal.
/// Two themes: [ZenColors.light] and [ZenColors.dark].
/// Never use hex values directly — always reference a token.
class ZenColors {
  const ZenColors._({
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceFaint,
    required this.accent,
    required this.accentMuted,
    required this.accentFaint,
    required this.destructive,
  });

  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSunken;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceFaint;
  final Color accent;
  final Color accentMuted;
  final Color accentFaint;
  final Color destructive;

  // ── Zen (light) ────────────────────────────────────────────────────────────

  static const light = ZenColors._(
    surface: Color(0xFFF7F3EE),
    surfaceElevated: Color(0xFFF0EAE2),
    surfaceSunken: Color(0xFFE8E0D5),
    onSurface: Color(0xFF2A2520),
    onSurfaceMuted: Color(0xFF7A6F65),
    onSurfaceFaint: Color(0xFFB8AFA6),
    accent: Color(0xFF7B9E87),
    accentMuted: Color(0xFFA8BFB0),
    accentFaint: Color(0xFFD6E4DA),
    destructive: Color(0xFFB5746A),
  );

  // ── Dark ───────────────────────────────────────────────────────────────────

  static const dark = ZenColors._(
    surface: Color(0xFF18161A),
    surfaceElevated: Color(0xFF211E24),
    surfaceSunken: Color(0xFF141216),
    onSurface: Color(0xFFEDE9E4),
    onSurfaceMuted: Color(0xFF8A8485),
    onSurfaceFaint: Color(0xFF4A4448),
    accent: Color(0xFF7B9E87),
    accentMuted: Color(0xFF5A7A66),
    accentFaint: Color(0xFF243028),
    destructive: Color(0xFFB5746A),
  );
}
