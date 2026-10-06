// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_provider.freezed.dart';
part 'catalog_provider.g.dart';

/// Loaded Catalog; [loadMore] is idle (`AsyncData(null)`), loading or failed.
@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    required List<Product> items,
    required int total,
    @Default(AsyncData<void>(null)) AsyncValue<void> loadMore,
  }) = _CatalogState;
}

/// First page of the Catalog, or of the search for the debounced term (AD-6).
///
/// A failure ends as `AsyncError(Errors)`.
@riverpod
class Catalog extends _$Catalog {
  // Bumped on every build(); a late page from an older build is dropped.
  var _epoch = 0;
  late String _term;
  late CancelSignal _cancel;

  @override
  Future<CatalogState> build() async {
    _epoch++;
    final cancel = _cancel = CancelSignal();
    ref.onDispose(cancel.cancel);
    final term = _term = ref.watch(
      debouncedTermProvider.select((a) => a.value ?? ''),
    );
    final result = await _fetch(term, cancel: cancel);
    final page = result.getOrThrow();
    return CatalogState(items: page.items, total: page.total);
  }

  Future<Either<Errors, Page<Product>>> _fetch(
    String term, {
    required CancelSignal cancel,
    int skip = 0,
  }) {
    final repository = ref.read(productRepositoryProvider);
    return term.isEmpty
        ? repository.list(skip: skip, cancel: cancel)
        : repository.search(term, skip: skip, cancel: cancel);
  }

  /// Appends the next page; ignored while one is in flight or none is left.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.loadMore.isLoading ||
        current.items.length >= current.total) {
      return;
    }
    final epoch = _epoch;
    state = AsyncData(current.copyWith(loadMore: const AsyncLoading()));
    final result = await _fetch(
      _term,
      cancel: _cancel,
      skip: current.items.length,
    );
    if (epoch != _epoch) return;
    // Re-read: the list is only ever replaced, never mutated (AD-5).
    final latest = state.requireValue;
    state = AsyncData(
      result.fold(
        (errors) =>
            latest.copyWith(loadMore: AsyncError(errors, StackTrace.current)),
        (page) => latest.copyWith(
          items: [...latest.items, ...page.items],
          total: page.total,
          loadMore: const AsyncData(null),
        ),
      ),
    );
  }
}
