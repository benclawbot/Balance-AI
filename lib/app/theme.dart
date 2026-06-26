import 'package:flutter/material.dart';

class MindfulColors {
  static const surface = Color(0xFFFCF9EF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F4EA);
  static const surfaceContainer = Color(0xFFF0EEE4);
  static const surfaceContainerHigh = Color(0xFFEAE8DE);
  static const surfaceVariant = Color(0xFFE5E3D9);
  static const onSurface = Color(0xFF1B1C16);
  static const onSurfaceVariant = Color(0xFF464742);
  static const outline = Color(0xFF767872);
  static const paperOffWhite = Color(0xFFE8E6DC);
  static const clayAccent = Color(0xFFD97757);
  static const amberHighlight = Color(0xFFEDA100);
  static const inkBlack = Color(0xFF141413);
  static const charcoal = Color(0xFF30302E);
}

class MindfulTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MindfulColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MindfulColors.clayAccent,
        brightness: Brightness.light,
        primary: MindfulColors.inkBlack,
        onPrimary: Colors.white,
        secondary: MindfulColors.clayAccent,
        surface: MindfulColors.surface,
        onSurface: MindfulColors.onSurface,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 48,
          fontWeight: FontWeight.w600,
          height: 56 / 48,
          letterSpacing: -0.96,
          color: MindfulColors.inkBlack,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 32,
          fontWeight: FontWeight.w500,
          height: 40 / 32,
          letterSpacing: -0.32,
          color: MindfulColors.inkBlack,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: MindfulColors.inkBlack,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 28 / 18,
          color: MindfulColors.inkBlack,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: MindfulColors.inkBlack,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.6,
          color: MindfulColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: MindfulColors.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: MindfulColors.inkBlack.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MindfulColors.clayAccent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MindfulColors.inkBlack,
          side: BorderSide(color: MindfulColors.inkBlack.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: MindfulColors.clayAccent,
        inactiveTrackColor: MindfulColors.surfaceContainerHigh,
        thumbColor: MindfulColors.inkBlack,
        overlayColor: MindfulColors.clayAccent.withValues(alpha: 0.16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MindfulColors.inkBlack,
        indicatorColor: MindfulColors.clayAccent.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.white.withValues(alpha: 0.58),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.white.withValues(alpha: 0.58),
          ),
        ),
      ),
    );
  }
}
