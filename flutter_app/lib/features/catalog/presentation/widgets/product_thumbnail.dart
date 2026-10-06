import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';

/// Square product image (56 px by default); a missing or failing one shows
/// "Sin foto", not an error.
class ProductThumbnail extends StatelessWidget {
  const new({
    required this.url,
    required this.title,
    this.size = 56,
    super.key,
  });

  final String url;
  final String title;

  final double size;

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
                  placeholder: (context, _) => ColoredBox(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
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
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSecondaryContainer;
    return ColoredBox(
      color: theme.colorScheme.secondaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 20, color: color),
          Text(
            context.t.noPhoto,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
