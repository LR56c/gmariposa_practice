import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';

/// 56 px thumbnail; a missing or failing image shows "Sin foto", not an error.
class ProductThumbnail extends StatelessWidget {
  /// Creates the thumbnail.
  const new({required this.url, required this.title, super.key});

  /// Image URL; empty means no photo.
  final String url;

  /// Product title, used as the accessibility label.
  final String title;

  /// Side of the square thumbnail.
  static const size = 56.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: size,
          child: url.isEmpty
              ? const _NoPhoto()
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.skeleton),
                  errorWidget: (_, _, _) => const _NoPhoto(),
                ),
        ),
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.placeholder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 20, color: AppColors.onPlaceholder),
          Text(
            'Sin foto',
            style: TextStyle(fontSize: 10, color: AppColors.onPlaceholder),
          ),
        ],
      ),
    );
  }
}
