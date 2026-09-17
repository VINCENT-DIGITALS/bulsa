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

abstract final class BulsaShadows {
  static const card = [
    BoxShadow(color: Color(0x142F2F32), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const navigation = [
    BoxShadow(color: Color(0x102F2F32), blurRadius: 18, offset: Offset(0, -4)),
  ];
}

abstract final class BulsaSpacing {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 24.0;
  static const xxLarge = 32.0;

  // Semantic aliases keep page, component, and section rhythm intentional.
  static const screenHorizontal = large;
  static const screenTop = xLarge;
  static const screenBottom = xxLarge;
  static const headerToContent = xLarge;
  static const section = xLarge;
  static const card = large;
  static const prominentCard = xLarge;
  static const actionGap = small;
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
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: BulsaColors.black,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: BulsaColors.black,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        color: BulsaColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      bodyLarge: TextStyle(color: BulsaColors.black, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(
        color: BulsaColors.black,
        fontSize: 14,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        color: BulsaColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: BulsaColors.black,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BulsaColors.background,
      foregroundColor: BulsaColors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: BulsaColors.black.withValues(alpha: .08),
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
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: BulsaSpacing.large),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(BulsaRadii.control),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BulsaColors.black,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: BulsaSpacing.large),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        side: const BorderSide(color: BulsaColors.lightGray),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(BulsaRadii.control),
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(BulsaRadii.modal),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(BulsaRadii.control),
        borderSide: BorderSide(color: BulsaColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(BulsaRadii.control),
        borderSide: BorderSide(color: BulsaColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(BulsaRadii.control),
        borderSide: BorderSide(color: BulsaColors.primary, width: 2),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: BulsaColors.background,
      height: 72,
      indicatorColor: BulsaColors.primary,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: BulsaColors.black, fontWeight: FontWeight.w700),
      ),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: BulsaColors.black),
      ),
    ),
  );
}
