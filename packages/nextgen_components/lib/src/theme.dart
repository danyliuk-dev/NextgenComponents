import 'package:flutter/material.dart';
import 'tokens.dart';

abstract final class NgTheme {
  static ThemeData light({bool compact = false}) => _build(false, compact);
  static ThemeData dark({bool compact = false}) => _build(true, compact);
  static ThemeData _build(bool dark, bool compact) {
    final primary = dark ? NgTokens.darkPrimary : NgTokens.lightPrimary;
    final surface = dark ? NgTokens.darkSurface : NgTokens.lightSurface;
    final text = dark ? NgTokens.darkText : NgTokens.lightText;
    final border = dark ? NgTokens.darkBorder : NgTokens.lightBorder;
    final radius = BorderRadius.circular(NgTokens.radius);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? NgTokens.darkBackground : Colors.white,
          surface: surface,
          onSurface: text,
          error: dark ? NgTokens.darkError : NgTokens.lightError,
          outline: border,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: dark
          ? NgTokens.darkBackground
          : NgTokens.lightBackground,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      textTheme: Typography.material2021().black.apply(
        bodyColor: text,
        displayColor: text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: compact,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(
            64,
            compact ? NgTokens.compactControlHeight : NgTokens.controlHeight,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: NgTokens.fontSize),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          backgroundColor: surface,
          side: BorderSide(color: border),
          minimumSize: Size(
            64,
            compact ? NgTokens.compactControlHeight : NgTokens.controlHeight,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: text,
        indicatorColor: primary,
        dividerColor: border,
      ),
    );
  }
}
