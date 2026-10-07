import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/product_thumbnail.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:go_router/go_router.dart';

/// One Catalog row; the whole row opens the detail.
class ProductListItem extends StatelessWidget {
  const new({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => unawaited(context.push('/product/${product.id}')),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
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
                      '★ ${product.rating}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
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
        ),
      ),
    );
  }
}
