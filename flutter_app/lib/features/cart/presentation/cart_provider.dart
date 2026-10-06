import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/cart_logic.dart'
    as logic;
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

/// Sole owner of the Cart state; all logic lives in `cart_logic.dart` (AD-7).
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartItem> build() => const [];

  void add(Product product) => state = logic.addToCart(state, product);
}
