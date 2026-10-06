import 'package:flutter/material.dart';

/// Colors outside Material's `ColorScheme`, from `DESIGN.md`.
abstract final class AppColors {
  /// Rating star.
  static const star = Color(0xFF8A5A00);

  /// "Sin foto" background.
  static const placeholder = Color(0xFFCDE8E2);

  /// Text on [placeholder].
  static const onPlaceholder = Color(0xFF191C1B);

  /// Loading skeleton blocks.
  static const skeleton = Color(0xFFDCE5E1);
}

const _primary = Color(0xFF006A60);
const _surfaceTonal = Color(0xFFEDF3F0);
const _onSurface = Color(0xFF191C1B);

/// Light theme built from the `DESIGN.md` tokens (no seed derivation, so the
/// verified contrasts hold).
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: _primary,
      onSurface: _onSurface,
      outline: Color(0xFF6F7976),
      outlineVariant: Color(0xFFDCE5E1),
      error: Color(0xFFB3261E),
      surfaceContainerHighest: _surfaceTonal,
    ),
    scaffoldBackgroundColor: const Color(0xFFFBFDFA),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceTonal,
      foregroundColor: _onSurface,
      toolbarHeight: 64,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w500,
        color: _onSurface,
      ),
    ),
    // The only FilledButton is the tonal "Reintentar" (button-tonal).
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
