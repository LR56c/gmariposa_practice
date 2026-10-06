import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/catalog/presentation/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/product_list_item.dart';
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

/// `/`: the Catalog with its loading, empty, error and data states.
class CatalogPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle)),
      body: catalog.when(
        // A retry from an error goes back to the loading state (AD-6).
        skipLoadingOnRefresh: false,
        loading: () =>
            Skeletonizer(child: _ProductList(products: _skeletonProducts)),
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
            : _ProductList(products: state.items),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const new({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => ProductListItem(product: products[i]),
    );
  }
}
