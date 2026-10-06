import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/presentation/provider/product_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_detail_provider.g.dart';

/// One Product by [id], loaded on its own (never from the Catalog).
///
/// A failure ends as `AsyncError(Errors)`.
@riverpod
Future<Product> productDetail(Ref ref, int id) async {
  final cancel = CancelSignal();
  ref.onDispose(cancel.cancel);
  final result = await ref
      .watch(productRepositoryProvider)
      .getById(id, cancel: cancel);
  return result.getOrThrow();
}
