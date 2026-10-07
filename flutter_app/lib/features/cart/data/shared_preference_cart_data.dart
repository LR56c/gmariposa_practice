import 'dart:async';

import 'dart:convert';

import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/domain/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [CartRepository] backed by `shared_preferences`: the Cart saved as JSON.
class SharedPreferenceCartData implements CartRepository {
  const new(this._prefs);

  static const key = 'cart';

  final SharedPreferences _prefs;

  /// A corrupt or outdated value is discarded and reads empty.
  @override
  List<CartItem> read() {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      return List.unmodifiable([
        for (final item in jsonDecode(raw) as List<Object?>)
          CartItem.fromJson(item! as Map<String, dynamic>),
      ]);
    } on Object {
      unawaited(_prefs.remove(key));
      return const [];
    }
  }

  @override
  Future<void> write(List<CartItem> items) =>
      _prefs.setString(key, jsonEncode([for (final i in items) i.toJson()]));
}
