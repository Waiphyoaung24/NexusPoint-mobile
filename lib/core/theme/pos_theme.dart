import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosTheme {
  // Color Constants
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color deepBlack = Color(0xFF020617);
  static const Color elevatedSurface = Color(0xFF0F172A);
  static const Color secondarySurface = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color incomingBlue = Color(0xFF3B82F6);
  static const Color dangerRed = Color(0xFFEF4444);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: amberWarning,
        surface: elevatedSurface,
        error: dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: deepBlack,

      // Typography
      textTheme: TextTheme(
        // Headers (Cinzel)
        headlineLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        headlineSmall: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.5,
        ),

        // Titles (Josefin Sans)
        titleLarge: GoogleFonts.josefinSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        // Body (Josefin Sans)
        bodyLarge: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.josefinSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),

        // Labels
        labelLarge: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.josefinSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.josefinSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: elevatedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          minimumSize: const Size(44, 44),
          textStyle: GoogleFonts.josefinSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondarySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: GoogleFonts.josefinSans(
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
        backgroundColor: elevatedSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cinzel(
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
        backgroundColor: elevatedSurface,
        selectedIconTheme: const IconThemeData(
          color: primaryGreen,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
        unselectedLabelTextStyle: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelType: NavigationRailLabelType.all,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Shadow Depths
  static BoxShadow shadowSm = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );

  static BoxShadow shadowMd = BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 6,
    offset: const Offset(0, 4),
  );

  static BoxShadow shadowLg = BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 15,
    offset: const Offset(0, 10),
  );

  // Status Colors
  static const Color statusOnline = Color(0xFF22C55E);
  static const Color statusOffline = Color(0xFF6B7280);
  static const Color statusSyncing = Color(0xFF3B82F6);
  static const Color statusError = Color(0xFFEF4444);
}
