import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mobile App Theme - Warm, Native iOS/Android Feel
/// Uses coral/orange tones to differentiate from web's green theme
class AppColors {
  // Primary - Warm Coral/Salmon (different from web's green)
  static const primary = Color(0xFFE85D4C);
  static const primaryLight = Color(0xFFFFAB9D);
  static const primaryDark = Color(0xFFC23B2A);
  static const primaryContainer = Color(0xFFFFDAD5);
  
  // Secondary - Deep Teal accent
  static const secondary = Color(0xFF00897B);
  static const secondaryLight = Color(0xFF4EBAAA);
  static const secondaryDark = Color(0xFF005B4F);
  
  // Verdict colors
  static const avoid = Color(0xFFB71C1C);
  static const avoidLight = Color(0xFFFFEBEE);
  static const avoidContainer = Color(0xFFFFCDD2);
  
  static const caution = Color(0xFFE65100);
  static const cautionLight = Color(0xFFFFF3E0);
  static const cautionContainer = Color(0xFFFFE0B2);
  
  static const preferred = Color(0xFF2E7D32);
  static const preferredLight = Color(0xFFE8F5E9);
  static const preferredContainer = Color(0xFFC8E6C9);
  
  static const unknown = Color(0xFF616161);
  static const unknownLight = Color(0xFFFAFAFA);
  static const unknownContainer = Color(0xFFEEEEEE);
  
  // Palestinian flag colors - used subtly
  static const palestineRed = Color(0xFFCE1126);
  static const palestineGreen = Color(0xFF007A3D);
  static const palestineBlack = Color(0xFF000000);
  
  // Surface colors - Clean whites and light grays for native feel
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  static const border = Color(0xFFE0E0E0);
  
  // Text colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFFBDBDBD);
  static const textOnPrimary = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.avoid,
      ),
      
      scaffoldBackgroundColor: AppColors.background,
      
      // Typography - System fonts for native feel
      fontFamily: 'SF Pro Display', // Falls back to system font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      
      // App Bar - iOS style
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // Bottom Navigation - iOS Tab Bar style
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      
      // Cards - Subtle shadows, rounded corners
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // List Tiles - iOS style
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        horizontalTitleGap: 12,
      ),
      
      // Elevated Button - Filled, rounded
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input - iOS style text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.avoid, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 17,
        ),
      ),
      
      // Chip - Tag style
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),
      
      // Bottom Sheet - iOS style
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static ThemeData get dark {
    // TODO: Implement dark theme
    return light;
  }
}

// Verdict styling helper
class VerdictStyles {
  static Color getBackgroundColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'AVOID':
        return AppColors.avoidLight;
      case 'CAUTION':
        return AppColors.cautionLight;
      case 'PREFERRED':
        return AppColors.preferredLight;
      default:
        return AppColors.unknownLight;
    }
  }
  
  static Color getColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'AVOID':
        return AppColors.avoid;
      case 'CAUTION':
        return AppColors.caution;
      case 'PREFERRED':
        return AppColors.preferred;
      default:
        return AppColors.unknown;
    }
  }
  
  static Color getContainerColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'AVOID':
        return AppColors.avoidContainer;
      case 'CAUTION':
        return AppColors.cautionContainer;
      case 'PREFERRED':
        return AppColors.preferredContainer;
      default:
        return AppColors.unknownContainer;
    }
  }
  
  static String getIcon(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'AVOID':
        return '✕';
      case 'CAUTION':
        return '⚠️';
      case 'PREFERRED':
        return '✓';
      default:
        return '؟';
    }
  }
}
