import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiao_cliente/themes/app_colors.dart';

class AppThemes {
  // **🌞 TEMA LIGHT MODERNO**
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // **Esquema de Cores**
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightTertiary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      error: AppColors.lightError,
      onError: Colors.white,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
    ),

    // **AppBar Theme**
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightPrimary,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // **Card Theme**
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // **Elevated Button Theme**
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // **Text Button Theme**
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // **Input Decoration Theme**
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.lightOutline,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.lightOutline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.lightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.lightError,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: AppColors.lightOnSurface.withOpacity(0.6),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppColors.lightOnSurface.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // **Typography**
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightOnBackground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.6,
      ),
    ),

    // **Floating Action Button Theme**
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // **Chip Theme**
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurfaceVariant,
      selectedColor: AppColors.lightPrimary,
      disabledColor: AppColors.lightOutline,
      labelStyle: const TextStyle(
        color: AppColors.lightOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.lightOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(
        color: AppColors.lightOutline,
        width: 1,
      ),
    ),
  );

  // **🌙 TEMA DARK MODERNO**
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // **Esquema de Cores**
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkTertiary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      error: AppColors.darkError,
      onError: AppColors.darkBackground,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
    ),

    // **AppBar Theme**
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkPrimary,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // **Card Theme**
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // **Elevated Button Theme**
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // **Text Button Theme**
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // **Input Decoration Theme**
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.darkOutline,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.darkOutline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.darkPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.darkError,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: AppColors.darkOnSurface.withOpacity(0.6),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: AppColors.darkOnSurface.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // **Typography**
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkOnBackground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.6,
      ),
    ),

    // **Floating Action Button Theme**
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkOnPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // **Chip Theme**
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceVariant,
      selectedColor: AppColors.darkPrimary,
      disabledColor: AppColors.darkOutline,
      labelStyle: const TextStyle(
        color: AppColors.darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.darkOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(
        color: AppColors.darkOutline,
        width: 1,
      ),
    ),
  );
}