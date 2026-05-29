import 'package:flutter/material.dart';

class AppTheme {
  // Colors from Figma design
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundAlt = Color(0xFFF9F9F9);
  static const Color textPrimary = Color(0xFF2D3435);
  static const Color textSecondary = Color(0xFF5A6061);
  static const Color textMuted = Color(0xFFADB3B4);
  static const Color accent = Color(0xFF745C00); // gold accent
  static const Color accentLight = Color(0xFFF5EDD0);
  static const Color border = Color(0xFFE8EAEB);
  static const Color cardBg = Color(0xFFF2F4F4);
  static const Color overlayDark = Color(0xFF1A1F20);
  static const Color errorColor = Color(0xFFB00020);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          background: background,
          surface: background,
          primary: textPrimary,
          secondary: accent,
          onBackground: textPrimary,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: background,
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.6,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: textPrimary,
            foregroundColor: background,
            elevation: 0,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: const BorderSide(color: border, width: 1),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: backgroundAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: textPrimary, width: 1.5),
          ),
          labelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: textSecondary,
          ),
          hintStyle: TextStyle(
            fontSize: 14,
            color: textMuted,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
          space: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: background,
          selectedItemColor: textPrimary,
          unselectedItemColor: textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
          elevation: 0,
        ),
      );

  static TextTheme get _textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: 9.6,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: 5.4,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.8,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.4,
          color: textSecondary,
        ),
      );
}
