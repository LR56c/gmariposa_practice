import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/domain/product_category.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_provider.g.dart';

/// Slug of the chosen category, or `null` for "Todas"; sync, no network (AD-5).
@Riverpod(keepAlive: true)
class SelectedCategory extends _$SelectedCategory {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties, a Notifier has no setter API.
  void set(String? slug) => state = slug;
}

/// Categories for the selector. A failure leaves the Catalog without it (AD-4).
@Riverpod(keepAlive: true)
Future<List<ProductCategory>> categories(Ref ref) async {
  final cancel = CancelSignal();
  ref.onDispose(cancel.cancel);
  final result = await ref
      .read(productRepositoryProvider)
      .categories(cancel: cancel);
  return result.getOrThrow();
}
