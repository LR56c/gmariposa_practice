import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/product_thumbnail.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One Cart row: thumbnail, title, unit price, −/+ and a separate "Quitar".
class CartItemTile extends ConsumerWidget {
  const new({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final product = item.product;
    final cart = ref.read(cartProvider.notifier);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  ProductThumbnail(url: product.imageUrl, title: product.title),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          product.price.toStringAsFixed(2),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 8, color: scheme.outlineVariant),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.error,
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => cart.remove(product.id),
                    child: Text(context.t.remove),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: context.t.decreaseQuantity(
                            title: product.title,
                          ),
                          icon: const Icon(Icons.remove),
                          // Minimum 1: "Quitar" drops the item.
                          onPressed: item.quantity > 1
                              ? () => cart.decrease(product.id)
                              : null,
                        ),
                        Text(
                          '${item.quantity}',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          tooltip: context.t.increaseQuantity(
                            title: product.title,
                          ),
                          icon: const Icon(Icons.add),
                          onPressed: () => cart.increase(product.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
