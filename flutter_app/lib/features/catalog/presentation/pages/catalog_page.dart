import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/catalog/presentation/widgets/product_list_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Layout the skeleton is drawn from while the first page loads.
final List<Product> _skeletonProducts = List.filled(
  6,
  const Product(
    id: 0,
    title: 'Product title',
    price: 0,
    rating: 0,
    imageUrl: '',
  ),
);

/// Distance from the list end at which the next page is requested (NFR5).
const loadMoreThreshold = 200.0;

/// `/`: the Catalog with its loading, empty, error and data states.
class CatalogPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.appTitle),
        actions: const [CartIconButton()],
      ),
      // The AppBar already covers the top inset.
      body: const SafeArea(
        top: false,
        child: Column(
          children: [
            _SearchField(),
            Expanded(child: _CatalogBody()),
          ],
        ),
      ),
    );
  }
}

class _CatalogBody extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return ref
        .watch(catalogProvider)
        .when(
          // A retry from an error goes back to the loading state (AD-6).
          skipLoadingOnRefresh: false,
          loading: () => Skeletonizer(
            child: _ProductList(
              state: CatalogState(items: _skeletonProducts, total: 99),
            ),
          ),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(catalogProvider),
          ),
          data: (state) => state.items.isEmpty
              ? Center(
                  child: Text(
                    t.emptyCatalog,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : _ProductList(state: state),
        );
  }
}

/// Pill search field (UX-DR6); keeps its text across navigation.
class _SearchField extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(
    text: ref.read(searchTermProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: ref.read(searchTermProvider.notifier).set,
          decoration: InputDecoration(
            hintText: context.t.searchHint,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            contentPadding: EdgeInsets.zero,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductList extends ConsumerStatefulWidget {
  const new({required this.state});

  final CatalogState state;

  @override
  ConsumerState<_ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<_ProductList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;
    if (position.extentAfter <= loadMoreThreshold) {
      unawaited(ref.read(catalogProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.all(16),
      // One extra row for the footer.
      itemCount: state.items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => i < state.items.length
          ? ProductListItem(product: state.items[i])
          : _Footer(state: state),
    );
  }
}

class _Footer extends ConsumerWidget {
  const new({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    if (state.items.isEmpty) return const SizedBox.shrink();
    final child = state.loadMore.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () => unawaited(ref.read(catalogProvider.notifier).loadMore()),
      ),
      data: (_) => state.items.length >= state.total
          ? Center(
              child: Text(
                t.noMoreProducts,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : const SizedBox.shrink(),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: child,
    );
  }
}
