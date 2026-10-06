import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/domain/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:fpdart/fpdart.dart';

/// Source of [Product]s.
abstract interface class ProductRepository {
  Future<Either<Errors, Page<Product>>> list({
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  });

  Future<Either<Errors, Page<Product>>> search(
    String query, {
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  });
}
