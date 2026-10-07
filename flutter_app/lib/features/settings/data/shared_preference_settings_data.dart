import 'package:flutter/material.dart';
import 'package:flutter_app/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SettingsRepository] backed by `shared_preferences`.
class SharedPreferenceSettingsData implements SettingsRepository {
  const new(this._prefs);

  static const themeKey = 'theme_mode';
  static const languageKey = 'language';

  final SharedPreferences _prefs;

  /// An unknown or missing value follows the system theme.
  @override
  ThemeMode readThemeMode() => ThemeMode.values.firstWhere(
    (m) => m.name == _prefs.getString(themeKey),
    orElse: () => ThemeMode.system,
  );

  @override
  String? readLanguage() => _prefs.getString(languageKey);

  @override
  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(themeKey, mode.name);

  @override
  Future<void> writeLanguage(String code) =>
      _prefs.setString(languageKey, code);
}
