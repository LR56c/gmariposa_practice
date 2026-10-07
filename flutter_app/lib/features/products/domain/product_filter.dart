import 'package:flutter_app/features/products/domain/product.dart';

/// Products whose title contains [term], ignoring case.
List<Product> filterByTitle(List<Product> products, String term) {
  final needle = term.toLowerCase();
  return [
    for (final p in products)
      if (p.title.toLowerCase().contains(needle)) p,
  ];
}
