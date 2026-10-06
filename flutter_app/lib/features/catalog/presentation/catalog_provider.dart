// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/data/product_repository_impl.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_provider.freezed.dart';
part 'catalog_provider.g.dart';

/// Loaded Catalog; [loadMore] stays idle (`AsyncData(null)`) until story 1.5.
@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    required List<Product> items,
    required int total,
    @Default(AsyncData<void>(null)) AsyncValue<void> loadMore,
  }) = _CatalogState;
}

/// First page of the Catalog (AD-6); a failure ends as `AsyncError(Errors)`.
@riverpod
class Catalog extends _$Catalog {
  @override
  Future<CatalogState> build() async {
    final cancel = CancelSignal();
    ref.onDispose(cancel.cancel);
    final result = await ref
        .watch(productRepositoryProvider)
        .list(cancel: cancel);
    final page = result.getOrThrow();
    return CatalogState(items: page.items, total: page.total);
  }
}
