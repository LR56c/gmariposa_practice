import 'package:flutter/material.dart';

const _primary = Color(0xFF006A60);
const _surfaceTonal = Color(0xFFEDF3F0);
const _onSurface = Color(0xFF191C1B);

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: _primary,
      onSurface: _onSurface,
      onSurfaceVariant: Color(0xFF4A5650),
      outline: Color(0xFF6F7976),
      outlineVariant: Color(0xFFDCE5E1),
      error: Color(0xFFB3261E),
      tertiary: Color(0xFF8A5A00),
      secondaryContainer: Color(0xFFCDE8E2),
      onSecondaryContainer: _onSurface,
      surfaceContainerHighest: _surfaceTonal,
    ),
    scaffoldBackgroundColor: const Color(0xFFFBFDFA),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceTonal,
      foregroundColor: _onSurface,
      toolbarHeight: 64,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: const StadiumBorder(),
        backgroundColor: _surfaceTonal,
        foregroundColor: _primary,
      ),
    ),
  );
}
