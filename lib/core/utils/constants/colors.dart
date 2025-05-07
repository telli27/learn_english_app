import 'package:flutter/material.dart';

class AppColors {
  // Primary and secondary colors
  static const Color primary = Color(0xFF4F6CFF);
  static const Color secondary = Color(0xFF00BFA5);
  static const Color accent = Color(0xFFFF375F);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);

  // Other colors
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Get color by name string
  static Color getColorByName(String colorName) {
    if (colorName.isEmpty) return primary;

    // If color starts with #, it's a hex color
    if (colorName.startsWith('#')) {
      try {
        // Convert hex to color
        final hexColor = colorName.replaceFirst('#', '');
        return Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        return primary;
      }
    }

    // Otherwise try to match to our predefined colors
    switch (colorName.toLowerCase()) {
      case 'blue':
        return const Color(0xFF4F6CFF);
      case 'purple':
        return const Color(0xFF7B61FF);
      case 'green':
        return const Color(0xFF00BFA5);
      case 'orange':
        return const Color(0xFFFF9500);
      case 'red':
        return const Color(0xFFFF3B30);
      case 'teal':
        return const Color(0xFF5AC8FA);
      case 'pink':
        return const Color(0xFFFF375F);
      case 'yellow':
        return const Color(0xFFFFCC00);
      default:
        return primary;
    }
  }
}
