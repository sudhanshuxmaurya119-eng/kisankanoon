import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color bgGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color orange = Color(0xFFFF9500);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textMid = Color(0xFF616161);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGreen,
        surface: white,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.notoSansDevanagariTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 28, fontWeight: FontWeight.bold, color: textDark,
        ),
        headlineMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 20, fontWeight: FontWeight.w700, color: textDark,
        ),
        titleLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark,
        ),
        titleMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 16, fontWeight: FontWeight.w600, color: textDark,
        ),
        bodyLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 14, fontWeight: FontWeight.w400, color: textDark,
        ),
        bodyMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 13, fontWeight: FontWeight.w400, color: textMid,
        ),
        labelSmall: GoogleFonts.notoSansDevanagari(
          fontSize: 11, fontWeight: FontWeight.w500, color: textLight,
        ),
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: white,
        titleTextStyle: GoogleFonts.notoSansDevanagari(
          fontSize: 18, fontWeight: FontWeight.w700, color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 16, fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
