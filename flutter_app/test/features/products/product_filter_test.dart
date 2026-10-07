import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/utils/product_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p(String title) =>
    Product(id: 1, title: title, price: 1, rating: 1, imageUrl: '');

void main() {
  test('matches the title ignoring case', () {
    final products = [_p('Essence Mascara'), _p('Red Lipstick')];

    expect(filterByTitle(products, 'MASCARA'), [products.first]);
    expect(filterByTitle(products, 'lip'), [products.last]);
  });

  test('returns an empty list when nothing matches or the list is empty', () {
    expect(filterByTitle([_p('Red Lipstick')], 'phone'), isEmpty);
    expect(filterByTitle(const [], 'phone'), isEmpty);
  });
}
