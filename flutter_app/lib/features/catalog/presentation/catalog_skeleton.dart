import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';

/// Six placeholder rows shown while the first page loads.
class CatalogSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _block(height: 56, width: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _block(height: 16, width: double.infinity),
              const SizedBox(height: 8),
              _block(height: 12, width: 64),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _block({required double height, required double width}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(height: height, width: width),
      );
}
