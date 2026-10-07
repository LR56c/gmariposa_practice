import 'package:flutter/material.dart';

/// Where the user's theme and language choices are saved between sessions.
abstract interface class SettingsRepository {
  ThemeMode readThemeMode();

  /// The saved language code (`es`, `en`), or null to follow the device.
  String? readLanguage();

  Future<void> writeThemeMode(ThemeMode mode);

  Future<void> writeLanguage(String code);
}
