import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_theme_service.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color orange = Color(0xFFFF9500);

  static const Color _lightWhite = Color(0xFFFFFFFF);
  static const Color _lightBgGreen = Color(0xFFE8F5E9);
  static const Color _lightBg = Color(0xFFF5F5F5);
  static const Color _lightTextDark = Color(0xFF212121);
  static const Color _lightTextMid = Color(0xFF616161);
  static const Color _lightTextLight = Color(0xFF9E9E9E);
  static const Color _lightDivider = Color(0xFFEEEEEE);
  static const Color _lightCardBg = Color(0xFFFFFFFF);
  static const Color _lightShadow = Color(0x1A000000);
  static const Color _warningOrange = Color(0xFFE65100);
  static const Color _warningSurfaceLight = Color(0xFFFFF3E0);

  static const Color _darkScaffold = Color(0xFF0F1512);
  static const Color _darkSurface = Color(0xFF18211D);
  static const Color _darkSurfaceVariant = Color(0xFF202A25);
  static const Color _darkPrimarySurface = Color(0xFF21362A);
  static const Color _darkTextPrimary = Color(0xFFF1F5F1);
  static const Color _darkTextSecondary = Color(0xFFC0CBC3);
  static const Color _darkTextTertiary = Color(0xFF8C9890);
  static const Color _darkDivider = Color(0xFF2E3A34);
  static const Color _darkCardBg = Color(0xFF18211D);
  static const Color _darkShadow = Color(0x52000000);
  static const Color _darkWarningSurface = Color(0xFF3A2B1A);
  static const Color _darkWarningText = Color(0xFFFFC27A);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static Color get white =>
      AppThemeService.isDarkMode ? _darkSurface : _lightWhite;

  static Color get bgGreen =>
      AppThemeService.isDarkMode ? _darkPrimarySurface : _lightBgGreen;

  static Color get bgLight =>
      AppThemeService.isDarkMode ? _darkScaffold : _lightBg;

  static Color get textDark =>
      AppThemeService.isDarkMode ? _darkTextPrimary : _lightTextDark;

  static Color get textMid =>
      AppThemeService.isDarkMode ? _darkTextSecondary : _lightTextMid;

  static Color get textLight =>
      AppThemeService.isDarkMode ? _darkTextTertiary : _lightTextLight;

  static Color get divider =>
      AppThemeService.isDarkMode ? _darkDivider : _lightDivider;

  static Color get cardBg =>
      AppThemeService.isDarkMode ? _darkCardBg : _lightCardBg;

  static Color get shadow =>
      AppThemeService.isDarkMode ? _darkShadow : _lightShadow;

  static Color get warningOrange =>
      AppThemeService.isDarkMode ? _darkWarningText : _warningOrange;

  static Color get warningSurfaceLight =>
      AppThemeService.isDarkMode ? _darkWarningSurface : _warningSurfaceLight;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldBackground(BuildContext context) =>
      isDark(context) ? _darkScaffold : _lightBg;

  static Color surface(BuildContext context) =>
      isDark(context) ? _darkSurface : _lightWhite;

  static Color surfaceVariant(BuildContext context) =>
      isDark(context) ? _darkSurfaceVariant : _lightBg;

  static Color primarySurface(BuildContext context) =>
      isDark(context) ? _darkPrimarySurface : _lightBgGreen;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? _darkTextPrimary : _lightTextDark;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? _darkTextSecondary : _lightTextMid;

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? _darkTextTertiary : _lightTextLight;

  static Color dividerColor(BuildContext context) =>
      isDark(context) ? _darkDivider : _lightDivider;

  static Color shadowColor(BuildContext context) =>
      isDark(context) ? _darkShadow : _lightShadow;

  static Color warningSurface(BuildContext context) =>
      isDark(context) ? _darkWarningSurface : _warningSurfaceLight;

  static Color warningText(BuildContext context) =>
      isDark(context) ? _darkWarningText : _warningOrange;

  static SystemUiOverlayStyle overlayStyleFor(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      return SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );
    }

    return SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool darkMode = brightness == Brightness.dark;
    final Color surfaceColor = darkMode ? _darkSurface : _lightWhite;
    final Color scaffoldColor = darkMode ? _darkScaffold : _lightBg;
    final Color surfaceVariantColor = darkMode ? _darkSurfaceVariant : _lightBg;
    final Color textPrimaryColor = darkMode ? _darkTextPrimary : _lightTextDark;
    final Color textSecondaryColor =
        darkMode ? _darkTextSecondary : _lightTextMid;
    final Color textTertiaryColor =
        darkMode ? _darkTextTertiary : _lightTextLight;
    final Color dividerColorValue = darkMode ? _darkDivider : _lightDivider;
    final Color shadowColorValue = darkMode ? _darkShadow : _lightShadow;
    final baseTextTheme = GoogleFonts.notoSansDevanagariTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGreen,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
      ).copyWith(
        surfaceContainerHighest: surfaceVariantColor,
      ),
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: surfaceColor,
      dividerColor: dividerColorValue,
      shadowColor: shadowColorValue,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),
        titleLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.notoSansDevanagari(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.notoSansDevanagari(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
        labelSmall: GoogleFonts.notoSansDevanagari(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiaryColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: surfaceColor,
        titleTextStyle: GoogleFonts.notoSansDevanagari(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
        systemOverlayStyle: darkMode
            ? overlayStyleFor(ThemeMode.dark)
            : overlayStyleFor(ThemeMode.light),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textTertiaryColor,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantColor,
        hintStyle: TextStyle(color: textTertiaryColor),
        labelStyle: TextStyle(color: textSecondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColorValue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColorValue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        prefixIconColor: textTertiaryColor,
        suffixIconColor: textTertiaryColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: _lightWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkMode ? _darkSurfaceVariant : _lightTextDark,
        contentTextStyle: TextStyle(
          color: darkMode ? _darkTextPrimary : _lightWhite,
        ),
      ),
    );
  }
}
