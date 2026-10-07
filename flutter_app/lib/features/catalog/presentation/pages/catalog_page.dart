import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/category_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/catalog/presentation/widgets/product_list_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_category.dart';
import 'package:flutter_app/features/settings/presentation/widgets/settings_icon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

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

/// `/`: the Catalog with its loading, empty, error and data states.
class CatalogPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.appTitle),
        actions: const [SettingsIconButton(), CartIconButton()],
      ),
      // The AppBar already covers the top inset.
      body: const SafeArea(
        top: false,
        child: Column(
          children: [
            _SearchField(),
            _CategoryButton(),
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
    final term = ref.watch(debouncedTermProvider.select((a) => a.value ?? ''));
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
            onRetry: () {
              ref.invalidate(catalogProvider);
              // The selector is gone if its own request failed too.
              if (ref.read(categoriesProvider).hasError) {
                ref.invalidate(categoriesProvider);
              }
            },
          ),
          data: (state) => state.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      term.isEmpty ? t.emptyCatalog : t.noResults(term: term),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
            // Visible focus ring (DESIGN.md: focus #0B57D0).
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: focusColor(context), width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the category modal; shows the chosen category (UX-DR24).
///
/// Hidden while categories load or if they fail, so the list is never blocked.
class _CategoryButton extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value;
    if (categories == null) return const SizedBox.shrink();
    final t = context.t;
    final slug = ref.watch(selectedCategoryProvider);
    final selected = categories.where((c) => c.slug == slug).firstOrNull;
    final label = selected?.name ?? t.category;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Semantics(
          button: true,
          label: t.categoryFilter(name: selected?.name ?? t.allCategories),
          excludeSemantics: true,
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => _showModal(context, ref, categories),
            icon: const Icon(Icons.filter_list),
            label: Text(label),
          ),
        ),
      ),
    );
  }

  void _showModal(
    BuildContext context,
    WidgetRef ref,
    List<ProductCategory> categories,
  ) {
    final t = context.t;
    final current = ref.read(selectedCategoryProvider);
    unawaited(
      WoltModalSheet.show<void>(
        context: context,
        pageListBuilder: (modalContext) => [
          SliverWoltModalSheetPage(
            mainContentSliversBuilder: (_) => [
              SliverList.list(
                children: [
                  _Option(
                    name: t.allCategories,
                    selected: current == null,
                    onTap: () => _choose(modalContext, ref, null),
                  ),
                  for (final c in categories)
                    _Option(
                      name: c.name,
                      selected: c.slug == current,
                      onTap: () => _choose(modalContext, ref, c.slug),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _choose(BuildContext modalContext, WidgetRef ref, String? slug) {
    ref.read(selectedCategoryProvider.notifier).set(slug);
    Navigator.of(modalContext).pop();
  }
}

/// Modal row; the check, not only the color, marks the selected one.
class _Option extends StatelessWidget {
  const new({required this.name, required this.selected, required this.onTap});

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: ListTile(
        minTileHeight: 48,
        title: Text(name),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: onTap,
      ),
    );
  }
}

/// The Catalog list; Riverpod owns the state and the library only renders it
/// and asks for the next page.
class _ProductList extends ConsumerWidget {
  const new({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final loadMore = state.loadMore;
    return PagedListView<int, Product>.separated(
      state: PagingState(
        pages: [state.items],
        keys: const [0],
        hasNextPage: state.items.length < state.total,
        isLoading: loadMore.isLoading,
        error: loadMore.error,
      ),
      fetchNextPage: () =>
          unawaited(ref.read(catalogProvider.notifier).loadMore()),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      builderDelegate: PagedChildBuilderDelegate<Product>(
        itemBuilder: (_, product, _) => ProductListItem(product: product),
        newPageProgressIndicatorBuilder: (_) => const _FooterPadding(
          child: Center(child: CircularProgressIndicator()),
        ),
        newPageErrorIndicatorBuilder: (_) => _FooterPadding(
          child: ErrorView(
            error: loadMore.error!,
            onRetry: () =>
                unawaited(ref.read(catalogProvider.notifier).loadMore()),
          ),
        ),
        noMoreItemsIndicatorBuilder: (context) => _FooterPadding(
          child: Center(
            child: Text(
              t.noMoreProducts,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterPadding extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: child);
}
