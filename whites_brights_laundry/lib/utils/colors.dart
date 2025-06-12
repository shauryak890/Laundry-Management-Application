import 'package:flutter/material.dart';

class GlobalColors {
  // Primary App Colors
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color accentColor = Color(0xFFFFD600);  // Yellow
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);  // Green
  static const Color warningColor = Color(0xFFFFC107);  // Amber
  static const Color errorColor = Color(0xFFF44336);    // Red
  static const Color infoColor = Color(0xFF2196F3);     // Blue
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);   // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Grey
  static const Color textLight = Color(0xFFBDBDBD);     // Light Grey
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Almost White
  static const Color backgroundCard = Color(0xFFFFFFFF);  // White
  static const Color backgroundDark = Color(0xFF303030);  // Dark Grey
  
  // Order Status Colors
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA000); // Orange
      case 'processing':
        return const Color(0xFF2979FF); // Blue
      case 'in_progress':
        return const Color(0xFF9C27B0); // Purple
      case 'in_transit':
        return const Color(0xFF00BCD4); // Cyan
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
