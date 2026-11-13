import 'package:dio/dio.dart';

import '../models/product.dart';

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
}

class ProductRemoteDataSource {
  ProductRemoteDataSource()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://dummyjson.com',
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<ProductPage> getProducts({
    required int limit,
    required int skip,
    String query = '',
  }) async {
    final path = query.trim().isEmpty ? '/products' : '/products/search';
    final response = await _dio.get(
      path,
      queryParameters: {
        'limit': limit,
        'skip': skip,
        if (query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return ProductPage(
      products: (data['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num).toInt(),
      skip: (data['skip'] as num).toInt(),
      limit: (data['limit'] as num).toInt(),
    );
  }

  Future<Product> addProduct(Product product) async {
    final response = await _dio.post('/products/add', data: product.toJson());
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(Product product) async {
    final response = await _dio.put(
      '/products/${product.id}',
      data: product.toJson(),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }
}
