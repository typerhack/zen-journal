import 'package:flutter/painting.dart';

/// Typography scale for Zen Journal.
/// Two font families: DMSerifDisplay (headings) + Inter (body).
/// All sizes in logical pixels. Never override textScaleFactor.
class ZenTextStyles {
  const ZenTextStyles._({required this.color});

  final Color color;

  static ZenTextStyles forColor(Color color) =>
      ZenTextStyles._(color: color);

  TextStyle get displayLarge => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 40,
        height: 1.2,
        letterSpacing: 0.5,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get displaySmall => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 28,
        height: 1.3,
        letterSpacing: 0.5,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get headingLarge => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 22,
        height: 1.4,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get headingSmall => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 18,
        height: 1.4,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.6,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.6,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.5,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get caption => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        height: 1.4,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.4,
        color: color,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      );

  TextStyle get mono => TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        height: 1.5,
        color: color,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );
}
