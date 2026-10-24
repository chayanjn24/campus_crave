import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm charcoal base with a saffron accent: reads as food, stays easy on the eyes at night.
abstract final class AppColors {
  static const bg = Color(0xFF131110);
  static const surface = Color(0xFF1D1A18);
  static const surfaceHigh = Color(0xFF292522);
  static const outline = Color(0xFF38322D);
  static const brand = Color(0xFFFF8A3D);
  static const onBrand = Color(0xFF221005);
  static const amber = Color(0xFFF5C451);
  static const sky = Color(0xFF8EC5FF);
  static const text = Color(0xFFF6F0EA);
  static const muted = Color(0xFFA89D93);
  static const veg = Color(0xFF5FD38D);
  static const nonVeg = Color(0xFFF26D5B);
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  // google_fonts 9 builds TextThemes from package:material_ui, so take just the
  // font families and apply them to Flutter's own TextTheme.
  // ThemeData.textTheme has no sizes until Theme.of localizes it, so start from a
  // sized theme: widgets that read styles directly (e.g. AppBar titles) need them.
  final sized = Typography.englishLike2021.merge(base.textTheme);
  final body = sized.apply(fontFamily: GoogleFonts.inter().fontFamily);
  final display = sized.apply(fontFamily: GoogleFonts.spaceGrotesk().fontFamily);
  final text = body
      .copyWith(
        displayLarge: display.displayLarge,
        displayMedium: display.displayMedium,
        displaySmall: display.displaySmall,
        headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1),
        headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.8),
        headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      )
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  final radius = BorderRadius.circular(16);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brand,
      onPrimary: AppColors.onBrand,
      secondary: AppColors.amber,
      onSecondary: AppColors.onBrand,
      tertiary: AppColors.sky,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      outline: AppColors.outline,
      error: AppColors.nonVeg,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onBrand,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: text.titleMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.brand,
      side: const BorderSide(color: AppColors.outline),
      shape: const StadiumBorder(),
      labelStyle: text.labelLarge,
      secondaryLabelStyle: text.labelLarge?.copyWith(color: AppColors.onBrand),
      checkmarkColor: AppColors.onBrand,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.brand,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? AppColors.onBrand : AppColors.muted),
      ),
      labelTextStyle: WidgetStateProperty.all(text.labelMedium),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.onBrand : AppColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.brand : AppColors.surfaceHigh,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: text.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
  );
}
