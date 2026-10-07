import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/category_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/catalog/presentation/widgets/product_list_item.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  child: Text(
                    term.isEmpty ? t.emptyCatalog : t.noResults(term: term),
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
            // Visible focus ring (DESIGN.md: focus #0B57D0).
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: Color(0xFF0B57D0), width: 2),
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
