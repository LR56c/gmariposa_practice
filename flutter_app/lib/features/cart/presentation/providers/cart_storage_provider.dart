import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/cart/data/cart_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_storage_provider.g.dart';

@Riverpod(keepAlive: true)
CartStorage cartStorage(Ref ref) =>
    CartStorage(ref.watch(sharedPreferencesProvider));
