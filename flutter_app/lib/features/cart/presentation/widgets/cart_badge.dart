import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Past this many units the badge shows "99+".
const maxBadgeCount = 99;

/// Cart icon with the unit counter; the badge is hidden with 0 units.
class CartBadge extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(cartCountProvider);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: units == 0
          ? context.t.cartLabelEmpty
          : context.t.cartLabelUnits(units: context.t.units(n: units)),
      excludeSemantics: true,
      child: Badge(
        isLabelVisible: units > 0,
        backgroundColor: scheme.error,
        textColor: scheme.onError,
        label: Text(units > maxBadgeCount ? '$maxBadgeCount+' : '$units'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
