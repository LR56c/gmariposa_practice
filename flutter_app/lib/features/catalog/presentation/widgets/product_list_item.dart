import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/features/catalog/presentation/widgets/product_thumbnail.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:go_router/go_router.dart';

/// One Catalog row; the whole row opens the detail.
class ProductListItem extends StatelessWidget {
  const new({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () => unawaited(context.push('/product/${product.id}')),
        leading: ProductThumbnail(url: product.imageUrl, title: product.title),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '★ ${product.rating}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        trailing: Text(
          product.price.toStringAsFixed(2),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
