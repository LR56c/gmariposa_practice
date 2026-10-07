import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/features/settings/presentation/providers/settings_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

/// The chosen [ThemeMode]; saving is best effort, the state stays the truth.
@Riverpod(keepAlive: true)
class ThemeModeChoice extends _$ThemeModeChoice {
  @override
  ThemeMode build() => ref.read(settingsRepositoryProvider).readThemeMode();

  void set(ThemeMode mode) {
    state = mode;
    unawaited(_save(mode));
  }

  Future<void> _save(ThemeMode mode) async {
    try {
      await ref.read(settingsRepositoryProvider).writeThemeMode(mode);
    } on Object {
      // Deliberately ignored: a failed write must not break the app.
    }
  }
}
