import 'dart:async';

import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_storage_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

/// Sole owner of the Cart state: an immutable list, replaced on each change.
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  List<CartItem> build() => ref.read(cartStorageProvider).read();

  /// Adds [product] with quantity 1, or bumps it if already in the Cart.
  void add(Product product) => _set(
    state.any((i) => i.product.id == product.id)
        ? _change(product.id, (i) => i.quantity + 1)
        : [...state, CartItem(product: product, quantity: 1)],
  );

  void increase(int productId) =>
      _set(_change(productId, (i) => i.quantity + 1));

  /// Never goes below 1; use [remove] to drop an item.
  void decrease(int productId) =>
      _set(_change(productId, (i) => i.quantity > 1 ? i.quantity - 1 : 1));

  void remove(int productId) =>
      _set(state.where((i) => i.product.id != productId).toList());

  // The in-memory state stays the source of truth; saving is best effort.
  void _set(List<CartItem> items) {
    state = items;
    unawaited(_save(items));
  }

  Future<void> _save(List<CartItem> items) async {
    try {
      await ref.read(cartStorageProvider).write(items);
    } on Object {
      // Deliberately ignored: a failed write must not break the Cart.
    }
  }

  List<CartItem> _change(int productId, int Function(CartItem) quantity) => [
    for (final i in state)
      if (i.product.id == productId) i.copyWith(quantity: quantity(i)) else i,
  ];
}

/// Sum of price × quantity, unrounded (round only when displaying).
@Riverpod(keepAlive: true)
double cartTotal(Ref ref) => ref
    .watch(cartProvider)
    .fold(0, (sum, i) => sum + i.product.price * i.quantity);

/// Sum of quantities, not the number of distinct items.
@Riverpod(keepAlive: true)
int cartCount(Ref ref) =>
    ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
