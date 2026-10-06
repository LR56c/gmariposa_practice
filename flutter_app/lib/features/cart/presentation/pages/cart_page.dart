import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_footer.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `/cart`: review and edit the Cart; the footer only exists with items.
class CartPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.t.cart),
      ),
      body: SafeArea(
        top: false,
        child: items.isEmpty
            ? Center(child: Text(context.t.cartEmpty))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) => CartItemTile(
                        key: ValueKey(items[i].product.id),
                        item: items[i],
                      ),
                    ),
                  ),
                  const CartFooter(),
                ],
              ),
      ),
    );
  }
}
