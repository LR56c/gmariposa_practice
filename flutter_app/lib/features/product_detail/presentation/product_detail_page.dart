import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/error_view.dart';
import 'package:flutter_app/core/widgets/not_found_view.dart';
import 'package:flutter_app/features/cart/presentation/cart_provider.dart';
import 'package:flutter_app/features/catalog/presentation/product_thumbnail.dart';
import 'package:flutter_app/features/product_detail/presentation/added_to_cart_toast.dart';
import 'package:flutter_app/features/product_detail/presentation/product_detail_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `/product/:id`: loads the Product by [id] with its loading and error states.
class ProductDetailPage extends ConsumerWidget {
  const new({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.t.appTitle),
      ),
      body: ref
          .watch(productDetailProvider(id))
          .when(
            // A retry from an error goes back to the loading state.
            skipLoadingOnRefresh: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            // A missing product stays missing: offer the way back, not a retry.
            error: (error, _) => error is Errors && error.isNotFound
                ? const NotFoundView()
                : ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(productDetailProvider(id)),
                  ),
            data: (product) => _DetailBody(product: product),
          ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const new({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ProductThumbnail(
                    url: product.imageUrl,
                    title: product.title,
                    size: 240,
                  ),
                ),
                const SizedBox(height: 16),
                Text(product.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  product.price.toStringAsFixed(2),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '★ ${product.rating}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          _AddToCartBar(product: product),
        ],
      ),
    );
  }
}

/// Full-width primary button pinned to the bottom.
class _AddToCartBar extends ConsumerWidget {
  const new({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              ref.read(cartProvider.notifier).add(product);
              showAddedToCartToast(context);
            },
            child: Text(context.t.addToCart),
          ),
        ),
      ),
    );
  }
}
