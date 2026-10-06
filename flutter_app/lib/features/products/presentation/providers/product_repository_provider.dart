import 'package:flutter_app/core/dio_provider.dart';
import 'package:flutter_app/features/products/data/dio_product_data.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) =>
    DioProductData(ref.watch(dioProvider));
