import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Bright Blue Accent
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  
  // Dark Theme Background Colors - Enhanced for better depth
  static const Color darkBackground = Color(0xFF0B0F1A); // Deeper, richer black-blue
  static const Color darkSurface = Color(0xFF151B2B);    // Enhanced surface with better contrast
  static const Color darkSurfaceVariant = Color(0xFF1E2535); // Subtle variant for headers
  static const Color darkSurfaceHover = Color(0xFF1E2838); // Lighter hover state
  static const Color darkSurfaceElevated = Color(0xFF1A2030); // For elevated cards

  // Light Theme Background Colors
  static const Color lightBackground = Color(0xFFFAFBFC); // Very light gray - cleaner look
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF8F9FA); // Slightly darker than background
  static const Color lightSurfaceHover = Color(0xFFF3F4F6);
  
  // Text Colors (Dark Mode)
  static const Color textPrimary = Color(0xFFF9FAFB);   // Gray-50
  static const Color textSecondary = Color(0xFF9CA3AF); // Gray-400
  static const Color textDisabled = Color(0xFF6B7280);  // Gray-500
  static const Color textMuted = Color(0xFF4B5563);     // Gray-600

  // Text Colors (Light Mode)
  static const Color lightTextPrimary = Color(0xFF111827); // Gray 900
  static const Color lightTextBody = Color(0xFF374151);    // Gray 700 - Better for body text
  static const Color lightTextSecondary = Color(0xFF5A5A5A); // Darkened from 0xFF4B5563 for better readability
  static const Color lightTextDisabled = Color(0xFF9CA3AF); // Gray 400
  
  // Status Colors
  static const Color success = Color(0xFF10B981);       // Modern green
  static const Color successDark = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);       // Modern orange
  static const Color warningDark = Color(0xFFD97706);
  static const Color error = Color(0xFFEF4444);         // Modern red
  static const Color errorDark = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);          // Modern blue
  
  // Stock Status Colors
  static const Color stockSufficient = Color(0xFF10B981); // Green
  static const Color stockLow = Color(0xFFF59E0B);        // Orange
  static const Color stockCritical = Color(0xFFEF4444);   // Red
  
  // Border and Divider
  // Border and Divider
  static const Color border = Color(0xFF374151);      // Gray-700
  static const Color borderLight = Color(0xFF4B5563); // Gray-600
  static const Color divider = Color(0xFF374151);     // Gray-700

  static const Color lightBorder = Color(0xFFE8EAED); // Slightly lighter border
  static const Color lightDivider = Color(0xFFE8EAED);
  
  // Hover and Focus States
  static const Color hover = Color(0xFF2A3142);
  static const Color focus = Color(0xFF3B82F6);
  
  // Chart Colors - Enhanced palette
  static const Color chartPrimary = Color(0xFF2196F3);
  static const Color chartSecondary = Color(0xFF8B5CF6);
  static const Color chartTertiary = Color(0xFF10B981);
  static const Color chartQuaternary = Color(0xFFF59E0B);
  static const Color chartQuinary = Color(0xFFEC4899);
  
  // Gradient Colors for Modern Cards
  static const Color gradientBlueStart = Color(0xFF2196F3);
  static const Color gradientBlueEnd = Color(0xFF1976D2);
  static const Color gradientGreenStart = Color(0xFF10B981);
  static const Color gradientGreenEnd = Color(0xFF059669);
  static const Color gradientOrangeStart = Color(0xFFF59E0B);
  static const Color gradientOrangeEnd = Color(0xFFD97706);
  static const Color gradientPurpleStart = Color(0xFF8B5CF6);
  static const Color gradientPurpleEnd = Color(0xFF7C3AED);
  
  // Badge Background Colors
  static const Color badgeSuccess = Color(0xFF065F46);
  static const Color badgeWarning = Color(0xFF92400E);
  static const Color badgeError = Color(0xFF991B1B);
  static const Color badgeInfo = Color(0xFF1E3A8A);
  
  // Light Theme Badge Backgrounds
  static const Color lightBadgeSuccess = Color(0xFFDCFCE7); // Green 100
  static const Color lightBadgeWarning = Color(0xFFFEF3C7); // Amber 100
  static const Color lightBadgeError = Color(0xFFFEE2E2);   // Red 100
  static const Color lightBadgeInfo = Color(0xFFDBEAFE);    // Blue 100
  static const Color lightBadgeNeutral = Color(0xFFF3F4F6); // Gray 100

  // Light Theme Badge Text
  static const Color lightBadgeTextSuccess = Color(0xFF166534); // Green 800
  static const Color lightBadgeTextWarning = Color(0xFF92400E); // Amber 800
  static const Color lightBadgeTextError = Color(0xFF991B1B);   // Red 800
  static const Color lightBadgeTextInfo = Color(0xFF1E40AF);    // Blue 800
  static const Color lightBadgeTextNeutral = Color(0xFF374151); // Gray 700
  
  // Input Colors - Enhanced for better visibility
  static const Color inputBackground = Color(0xFF1A2030);
  static const Color inputBorder = Color(0xFF2A3142);
  static const Color inputFocusBorder = Color(0xFF2196F3);
  
  // Icon Background Colors for Stat Cards
  static const Color iconBackgroundBlue = Color(0xFF1E3A8A);
  static const Color iconBackgroundGreen = Color(0xFF065F46);
  static const Color iconBackgroundOrange = Color(0xFF92400E);
  static const Color iconBackgroundPurple = Color(0xFF2D1B4E);
  static const Color iconBackgroundRed = Color(0xFF4A1A1A);
  
  // Light Theme Icon Backgrounds
  static const Color lightIconBackgroundBlue = Color(0xFFDBEAFE);
  static const Color lightIconBackgroundGreen = Color(0xFFDCFCE7);
  static const Color lightIconBackgroundOrange = Color(0xFFFEF3C7);
  static const Color lightIconBackgroundPurple = Color(0xFFF3E8FF);
  static const Color lightIconBackgroundRed = Color(0xFFFFE5E5);
}
