import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/features/catalog/presentation/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/catalog_skeleton.dart';
import 'package:flutter_app/features/catalog/presentation/product_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/`: the Catalog with its loading, empty, error and data states.
class CatalogPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Catálogo')),
      body: catalog.when(
        // A retry from an error goes back to the loading state (AD-6).
        skipLoadingOnRefresh: false,
        loading: () => const CatalogSkeleton(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(catalogProvider),
        ),
        data: (state) => state.items.isEmpty
            ? const Center(child: Text('No hay productos'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => ProductListItem(product: state.items[i]),
              ),
      ),
    );
  }
}
