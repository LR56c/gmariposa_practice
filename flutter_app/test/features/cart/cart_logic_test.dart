import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/cart_logic.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p(int id, double price) =>
    Product(id: id, title: 'P$id', price: price, rating: 4, imageUrl: '');

void main() {
  test('adds a new product with quantity 1', () {
    final items = addToCart(const [], _p(1, 10));
    expect(items, [CartItem(product: _p(1, 10), quantity: 1)]);
  });

  test('adding an existing product bumps quantity without duplicating', () {
    final items = addToCart(addToCart(const [], _p(1, 10)), _p(1, 10));
    expect(items.length, 1);
    expect(items.single.quantity, 2);
  });

  test('decrease never goes below 1 nor removes the item', () {
    final one = addToCart(const [], _p(1, 10));
    expect(decrease(one, 1).single.quantity, 1);
    expect(decrease(increase(one, 1), 1).single.quantity, 1);
    expect(increase(one, 1).single.quantity, 2);
  });

  test('remove drops the item, the last one leaves an empty list', () {
    final items = addToCart(addToCart(const [], _p(1, 10)), _p(2, 5));
    expect(remove(items, 1).map((i) => i.product.id), [2]);
    expect(remove(remove(items, 1), 2), isEmpty);
  });

  test('total and units over several quantities; input is not mutated', () {
    final items = [
      CartItem(product: _p(1, 10.5), quantity: 2),
      CartItem(product: _p(2, 5), quantity: 3),
    ];
    expect(total(items), 36);
    expect(units(items), 5);
    increase(items, 1);
    expect(items.first.quantity, 2);
  });
}
