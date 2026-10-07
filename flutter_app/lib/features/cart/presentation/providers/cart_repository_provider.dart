import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/cart/data/shared_preference_cart_data.dart';
import 'package:flutter_app/features/cart/domain/cart_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_repository_provider.g.dart';

@Riverpod(keepAlive: true)
CartRepository cartRepository(Ref ref) =>
    SharedPreferenceCartData(ref.watch(sharedPreferencesProvider));
