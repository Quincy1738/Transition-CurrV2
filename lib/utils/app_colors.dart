import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF3A7DDB); // Main blue
  static const Color primaryDark = Color(0xFF2A5FAE);
  static const Color primaryLight = Color(0xFFE3F2FD);

  // Secondary Colors
  static const Color secondary = Color(0xFF6C757D); // Gray
  static const Color secondaryDark = Color(0xFF495057);
  static const Color secondaryLight = Color(0xFFE9ECEF);

  // Accent Colors
  static const Color success = Color(0xFF28A745); // Green
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color danger = Color(0xFFDC3545); // Red
  static const Color info = Color(0xFF17A2B8); // Teal

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212529);

  // Skill Category Colors (matches your 7 categories)
  static const Map<String, Color> categoryColors = {
    'Care Skills': Color(0xFF20C997), // Green
    'Functional Academic Skills': Color(0xFF6F42C1), // Purple
    'Life Skills': Color(0xFFFD7E14), // Orange
    'Pre-Vocational Skills': Color(0xFF17A2B8), // Teal
    'Livelihood Skills': Color(0xFF343A40), // Dark gray
    'Enrichment Skills': Color(0xFFFFC107), // Yellow
    'Career Skills': Color(0xFF3A7DDB), // Blue
  };

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);

  // Borders
  static const Color borderLight = Color(0xFFDEE2E6);
  static const Color borderDark = Color(0xFFCED4DA);

  // Helper method to get contrast text color
  static Color getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}