import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overrides [sharedPreferencesProvider] with an in-memory instance.
Future<Override> prefsOverride([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return sharedPreferencesProvider.overrideWithValue(
    await SharedPreferences.getInstance(),
  );
}
