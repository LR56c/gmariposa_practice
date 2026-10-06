import 'package:flutter_app/features/catalog/presentation/catalog_page.dart';
import 'package:go_router/go_router.dart';

/// Single route for now; the detail and cart routes arrive in later stories.
final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const CatalogPage())],
);
