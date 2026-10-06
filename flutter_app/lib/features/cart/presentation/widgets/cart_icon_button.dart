import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:go_router/go_router.dart';

/// AppBar action that opens `/cart`, keeping the current screen in the stack.
class CartIconButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.t.cart,
      icon: const Icon(Icons.shopping_cart_outlined),
      onPressed: () => unawaited(context.push('/cart')),
    );
  }
}
