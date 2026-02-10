import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosTheme {
  // Color Constants - Light Theme with Blue & White
  static const Color primaryBlue = Color(0xFF1E40AF); // Blue-800
  static const Color secondaryBlue = Color(0xFF3B82F6); // Blue-500
  static const Color accentAmber = Color(0xFFF59E0B); // Amber-500
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure white
  static const Color textPrimary = Color(0xFF1E3A8A); // Blue-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color successGreen = Color(0xFF22C55E); // Green-500
  static const Color dangerRed = Color(0xFFEF4444); // Red-500

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: surfaceWhite,
        error: dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
        tertiary: accentAmber,
      ),

      scaffoldBackgroundColor: backgroundLight,

      // Typography (Poppins for headers, Open Sans for body)
      textTheme: TextTheme(
        // Headers (Poppins - Bold, modern)
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),

        // Titles (Poppins - Semi-bold)
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        // Body (Open Sans - Clean, readable)
        bodyLarge: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),

        // Labels (Open Sans - Medium weight)
        labelLarge: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.openSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: primaryBlue.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderLight,
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: borderLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryBlue,
          minimumSize: const Size(44, 44),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: GoogleFonts.openSans(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 1,
        shadowColor: primaryBlue.withValues(alpha: 0.1),
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaceWhite,
        elevation: 1,
        selectedIconTheme: const IconThemeData(
          color: primaryBlue,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryBlue,
        ),
        unselectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelType: NavigationRailLabelType.all,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Shadow Depths (Subtle for light theme)
  static BoxShadow shadowSm = BoxShadow(
    color: primaryBlue.withValues(alpha: 0.05),
    blurRadius: 4,
    offset: const Offset(0, 1),
  );

  static BoxShadow shadowMd = BoxShadow(
    color: primaryBlue.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static BoxShadow shadowLg = BoxShadow(
    color: primaryBlue.withValues(alpha: 0.12),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  // Status Colors
  static const Color statusOnline = successGreen;
  static const Color statusOffline = Color(0xFF94A3B8); // Slate-400
  static const Color statusSyncing = secondaryBlue;
  static const Color statusError = dangerRed;
}
