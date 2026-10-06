import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/catalog/presentation/product_thumbnail.dart';
import 'package:flutter_app/features/products/domain/product.dart';

/// One Catalog row; the whole row is the tap target (the tap arrives in 2.1).
class ProductListItem extends StatelessWidget {
  /// Creates the row.
  const new({required this.product, super.key});

  /// The product shown.
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ProductThumbnail(url: product.imageUrl, title: product.title),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '★ ${product.rating}',
          style: const TextStyle(color: AppColors.star),
        ),
        trailing: Text(
          product.price.toStringAsFixed(2),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
