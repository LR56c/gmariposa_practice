import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/settings/data/shared_preference_settings_data.dart';
import 'package:flutter_app/features/settings/domain/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository_provider.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SharedPreferenceSettingsData(ref.watch(sharedPreferencesProvider));
