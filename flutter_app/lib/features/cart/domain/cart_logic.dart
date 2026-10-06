import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';

// Pure Cart functions (AD-7): each returns a new list, never mutating [items].

/// Adds [product] with quantity 1, or bumps the quantity if it is already in.
List<CartItem> addToCart(List<CartItem> items, Product product) =>
    items.any((i) => i.product.id == product.id)
    ? increase(items, product.id)
    : [...items, CartItem(product: product, quantity: 1)];

List<CartItem> increase(List<CartItem> items, int productId) =>
    _map(items, productId, (i) => i.copyWith(quantity: i.quantity + 1));

/// Never goes below 1; use [remove] to drop an item.
List<CartItem> decrease(List<CartItem> items, int productId) => _map(
  items,
  productId,
  (i) => i.quantity > 1 ? i.copyWith(quantity: i.quantity - 1) : i,
);

List<CartItem> remove(List<CartItem> items, int productId) =>
    items.where((i) => i.product.id != productId).toList();

/// Sum of price × quantity, unrounded (round only when displaying).
double total(List<CartItem> items) =>
    items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

/// Sum of quantities, not the number of distinct items.
int units(List<CartItem> items) => items.fold(0, (sum, i) => sum + i.quantity);

List<CartItem> _map(
  List<CartItem> items,
  int productId,
  CartItem Function(CartItem) change,
) => [
  for (final i in items)
    if (i.product.id == productId) change(i) else i,
];
