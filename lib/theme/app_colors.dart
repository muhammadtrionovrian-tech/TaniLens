import 'package:flutter/material.dart';

/// Centralized Sage-Olive design tokens registry for Tani Lens matching Figma palette.
class AppColors {
  AppColors._();

  // ── Sage-Olive Palette Tokens ──
  static const Color primary = Color(0xFF687052);      // Darker Olive Sage (#687052)
  static const Color primaryLight = Color(0xFF8B956E); // Olive Sage (#8B956E)
  static const Color accent = Color(0xFFD6E5AB);       // Light Sage (#D6E5AB)
  static const Color accentDark = Color(0xFFB0BC8C);   // Sage Border (#B0BC8C)
  
  static const Color background = Color(0xFFF5F7EF);   // Soft light sage-white background
  static const Color surface = Colors.white;
  
  static const Color textDark = Color(0xFF282C1E);     // Very Dark Green (#282C1E)
  static const Color textMuted = Color(0xFF474C37);    // Muted Dark Olive (#474C37)
  static const Color textBlack = Color(0xFF10120A);    // Almost Black (#10120A)
}
