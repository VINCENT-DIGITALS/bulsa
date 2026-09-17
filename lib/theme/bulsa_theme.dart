import 'package:flutter/material.dart';

abstract final class BulsaColors {
  static const primary = Color(0xFFC59D62);
  static const background = Color(0xFFF8F8F8);
  static const lightGray = Color(0xFFE8E8E8);
  static const black = Color(0xFF2F2F32);
}

abstract final class BulsaRadii {
  static const small = Radius.circular(8);
  static const control = Radius.circular(12);
  static const container = Radius.circular(16);
  static const modal = Radius.circular(24);
}

ThemeData buildBulsaTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: BulsaColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: BulsaColors.primary,
        onPrimary: BulsaColors.black,
        surface: Colors.white,
        onSurface: BulsaColors.black,
        outline: BulsaColors.lightGray,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: BulsaColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: BulsaColors.background,
      foregroundColor: BulsaColors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(BulsaRadii.container),
        side: const BorderSide(color: BulsaColors.lightGray),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BulsaColors.primary,
        foregroundColor: BulsaColors.black,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(BulsaRadii.control),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BulsaColors.black,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: BulsaColors.lightGray),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(BulsaRadii.control),
        ),
      ),
    ),
  );
}
