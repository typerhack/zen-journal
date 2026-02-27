import 'package:flutter/animation.dart';

/// Spacing, radius, and animation tokens for Zen Journal.
/// All values derived from a 4-point base grid.
class ZenSpacing {
  // ignore: unused_element
  const ZenSpacing();

  // ── Spacing ────────────────────────────────────────────────────────────────

  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s64 = 64;

  /// Page margin — mobile
  static const double pageMarginMobile = s24;

  /// Page margin — tablet / desktop
  static const double pageMarginDesktop = s48;

  // ── Border radius ──────────────────────────────────────────────────────────

  static const double radiusSmall = 6;
  static const double radiusMedium = 12;
  static const double radiusLarge = 20;
  static const double radiusFull = 999;

  // ── Animation durations ────────────────────────────────────────────────────

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 600);

  // ── Animation curves ───────────────────────────────────────────────────────

  /// Default for all transitions — never use Curves.linear
  static const Curve easeDefault = Curves.easeInOut;

  /// Elements entering the screen
  static const Curve easeEnter = Curves.easeOut;

  /// Elements leaving the screen
  static const Curve easeExit = Curves.easeIn;
}
