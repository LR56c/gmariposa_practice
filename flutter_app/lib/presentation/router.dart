import 'package:flutter_app/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_app/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:flutter_app/presentation/not_found_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  errorBuilder: (_, _) => const NotFoundPage(),
  routes: [
    GoRoute(path: '/', builder: (_, _) => const CatalogPage()),
    GoRoute(path: '/cart', builder: (_, _) => const CartPage()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) {
        // Parsed once here; a non-numeric id never reaches the network.
        final id = int.tryParse(state.pathParameters['id']!);
        return id == null ? const NotFoundPage() : ProductDetailPage(id: id);
      },
    ),
  ],
);
