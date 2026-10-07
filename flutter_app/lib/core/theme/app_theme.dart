import 'package:flutter/material.dart';

/// Light and dark palettes share the same roles (DESIGN.md tokens).
ColorScheme _scheme(Brightness brightness) {
  return brightness == Brightness.dark
      ? const ColorScheme.dark(
          primary: Color(0xFF4FDBC8),
          onPrimary: Color(0xFF003731),
          surface: Color(0xFF171D1B),
          onSurface: Color(0xFFE0E4E1),
          onSurfaceVariant: Color(0xFFB0BAB5),
          outline: Color(0xFF8A9490),
          outlineVariant: Color(0xFF2E3835),
          error: Color(0xFFF2B8B5),
          tertiary: Color(0xFFF0B429),
          secondaryContainer: Color(0xFF1F3A35),
          onSecondaryContainer: Color(0xFFE0E4E1),
          surfaceContainerHighest: Color(0xFF1F2926),
        )
      : const ColorScheme.light(
          primary: Color(0xFF006A60),
          onSurface: Color(0xFF191C1B),
          onSurfaceVariant: Color(0xFF4A5650),
          outline: Color(0xFF6F7976),
          outlineVariant: Color(0xFFDCE5E1),
          error: Color(0xFFB3261E),
          tertiary: Color(0xFF8A5A00),
          secondaryContainer: Color(0xFFCDE8E2),
          onSecondaryContainer: Color(0xFF191C1B),
          surfaceContainerHighest: Color(0xFFEDF3F0),
        );
}

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final scheme = _scheme(brightness);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF0F1513)
        : const Color(0xFFFBFDFA),
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
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surfaceContainerHighest,
      foregroundColor: scheme.onSurface,
      toolbarHeight: 64,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: const StadiumBorder(),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    ),
  );
}

/// `button-tonal` from DESIGN.md: tonal surface with primary text.
ButtonStyle tonalButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: scheme.surfaceContainerHighest,
    foregroundColor: scheme.primary,
  );
}

/// Visible focus ring color (DESIGN.md: focus #0B57D0, lighter on dark).
Color focusColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF8AB4F8)
    : const Color(0xFF0B57D0);
