import 'package:flutter/material.dart';

// ==============================================
// APP THEME & COLOR SCHEME
// ==============================================

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF667eea);
  static const Color primaryDark = Color(0xFF764ba2);
  static const Color primaryLight = Color(0xFF7E8EF1);

  // Secondary Colors
  static const Color secondary = Color(0xFF4A90E2);
  static const Color secondaryDark = Color(0xFF2A5298);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4DABF7);

  // Role Colors
  static const Color adminColor = Color(0xFF9775FA);
  static const Color driverColor = Color(0xFFFF922B);
  static const Color studentColor = Color(0xFF4DABF7);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF1A1A2E);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  static const Color textWhite = Colors.white;

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFECF0F1);

  // Status Colors
  static const Color active = Color(0xFF51CF66);
  static const Color inactive = Color(0xFFADB5BD);
  static const Color moving = Color(0xFF4DABF7);
  static const Color stopped = Color(0xFFFF922B);
  static const Color breakdown = Color(0xFFFF6B6B);
}

// ----------------------------------------------------

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
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

// ----------------------------------------------------

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

// ----------------------------------------------------

class AppSizes {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 999.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeightSM = 40.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;
}

// ----------------------------------------------------

class AppDecorations {
  // Card Decoration
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // Glass Effect
  static BoxDecoration glass = BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
  );

  // Input Field
  static BoxDecoration inputField = BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
    border: Border.all(color: Colors.white.withOpacity(0.4)),
  );
}

// ----------------------------------------------------

// App Theme
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLG,
          vertical: AppSizes.paddingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),

    // CardTheme fix applied here
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLG)),
      ),
      color: AppColors.cardBackground,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppSizes.paddingMD),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.cardBackground,
      background: AppColors.background,
    ),
  );
}

// ----------------------------------------------------

// Status Helper
class StatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'moving':
        return AppColors.active;
      case 'stopped':
        return AppColors.stopped;
      case 'breakdown':
        return AppColors.breakdown;
      case 'inactive':
        return AppColors.inactive;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.adminColor;
      case 'driver':
        return AppColors.driverColor;
      case 'student':
        return AppColors.studentColor;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'driver':
        return Icons.person;
      case 'student':
        return Icons.school;
      default:
        return Icons.person_outline;
    }
  }
}

// ----------------------------------------------------

// Constants
class AppConstants {
  static const String appName = 'Bus Tracker';
  static const int locationUpdateInterval = 5; // seconds
  static const int notificationBeforeArrival = 10; // minutes
  static const double mapZoom = 15.0;
}