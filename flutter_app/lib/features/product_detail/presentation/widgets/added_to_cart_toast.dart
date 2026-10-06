import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:toastification/toastification.dart';

/// Brief "Agregado al carrito" toast; a new one replaces the previous (UX-DR9).
void showAddedToCartToast(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  toastification
    ..dismissAll(delayForAnimation: false)
    ..show(
      context: context,
      title: Text(context.t.addedToCart),
      style: ToastificationStyle.flat,
      primaryColor: scheme.primary,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      autoCloseDuration: const Duration(milliseconds: 2500),
      showProgressBar: false,
      // "Reduce motion": no entry/exit animation.
      animationDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
    );
}
