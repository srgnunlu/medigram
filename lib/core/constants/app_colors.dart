import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0066CC); // Medical Blue
  static const Color primaryDark = Color(0xFF004C99);
  static const Color primaryLight = Color(0xFF3385D6);

  // Secondary Colors
  static const Color secondary = Color(0xFF00C853); // Success Green
  static const Color secondaryDark = Color(0xFF009624);
  static const Color secondaryLight = Color(0xFF5EFC82);

  // Accent Colors
  static const Color accent = Color(0xFFFF6F00); // Premium Orange
  static const Color accentDark = Color(0xFFC43E00);
  static const Color accentLight = Color(0xFFFF9E40);

  // Background Colors (Dark Theme)
  static const Color background = Color(0xFF121212);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF4D4D4D);

  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFCF6679);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // UI Element Colors
  static const Color divider = Color(0xFF303030);
  static const Color border = Color(0xFF424242);
  static const Color shadow = Color(0x40000000);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Kardiyoloji': Color(0xFFE53935),
    'Nöroloji': Color(0xFF8E24AA),
    'Pediatri': Color(0xFFFB8C00),
    'Dahiliye': Color(0xFF43A047),
    'Cerrahi': Color(0xFF1E88E5),
    'Radyoloji': Color(0xFF00ACC1),
    'Psikiyatri': Color(0xFF5E35B1),
    'Onkoloji': Color(0xFFD81B60),
    'Ortopedi': Color(0xFF6D4C41),
    'Göz Hastalıkları': Color(0xFF00897B),
    'KBB': Color(0xFFF4511E),
    'Diğer': Color(0xFF757575),
  };

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Colors (for loading skeletons)
  static const Color shimmerBase = Color(0xFF2C2C2C);
  static const Color shimmerHighlight = Color(0xFF3D3D3D);

  // Get category color
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Diğer']!;
  }
}
