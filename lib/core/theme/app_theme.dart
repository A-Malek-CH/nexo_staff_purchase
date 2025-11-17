import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color lightBeige = Color(0xFFFFF8F0);
  static const Color creamBackground = Color(0xFFFFFBF5);
  static const Color darkGrey = Color(0xFF2D3436);
  static const Color mediumGrey = Color(0xFF636E72);
  static const Color lightGrey = Color(0xFFDFE6E9);
  static const Color successGreen = Color(0xFF00B894);
  static const Color errorRed = Color(0xFFD63031);
  static const Color warningYellow = Color(0xFFFDCB6E);
  static const Color white = Color(0xFFFFFFFF);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkGrey,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: darkGrey,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkGrey,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkGrey,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: mediumGrey,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: mediumGrey,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: lightBeige,
        surface: white,
        error: errorRed,
        onPrimary: white,
        onSecondary: darkGrey,
        onSurface: darkGrey,
        onError: white,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkGrey,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: buttonText,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryOrange, width: 2),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: bodyMedium,
        hintStyle: bodyMedium.copyWith(color: lightGrey),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkGrey,
        size: 24,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: mediumGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Border Radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius inputBorderRadius = BorderRadius.all(Radius.circular(12));
  
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  
  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(4);
  static const EdgeInsets paddingS = EdgeInsets.all(8);
  static const EdgeInsets paddingM = EdgeInsets.all(16);
  static const EdgeInsets paddingL = EdgeInsets.all(24);
  static const EdgeInsets paddingXL = EdgeInsets.all(32);
}
