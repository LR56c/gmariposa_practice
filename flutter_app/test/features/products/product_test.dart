import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

const _json = <String, Object?>{
  'id': 1,
  'title': 'Essence Mascara',
  'price': 10,
  'rating': 4.5,
  'thumbnail': 'https://img/1.png',
  'brand': 'ignored',
};

void main() {
  test('parses a DummyJSON product, mapping thumbnail to imageUrl', () {
    final product = Product.fromJson(_json);

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara');
    expect(product.price, 10.0);
    expect(product.rating, 4.5);
    expect(product.imageUrl, 'https://img/1.png');
  });

  test('throws when a required field is missing', () {
    final json = {..._json}..remove('title');

    expect(() => Product.fromJson(json), throwsA(isA<TypeError>()));
  });

  test('throws when a field has the wrong type', () {
    final json = {..._json, 'price': 'free'};

    expect(() => Product.fromJson(json), throwsA(isA<TypeError>()));
  });
}
