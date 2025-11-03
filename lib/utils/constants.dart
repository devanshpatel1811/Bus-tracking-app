import 'package:flutter/material.dart';

/// App-wide color scheme and constants
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF667eea);
  static const Color primaryDark = Color(0xFF764ba2);

  // Role-specific Colors
  static const Color adminColor = Color(0xFF9775FA);
  static const Color driverColor = Color(0xFFFF922B);
  static const Color studentColor = Color(0xFF4DABF7);

  // Status Colors
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4DABF7);

  // Background
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient admin = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient driver = LinearGradient(
    colors: [Color(0xFFFF922B), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient student = LinearGradient(
    colors: [Color(0xFF4DABF7), Color(0xFF667eea)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const String appName = 'Bus Tracker';
  static const int locationUpdateInterval = 5; // seconds
  static const int notificationBeforeArrival = 10; // minutes
}