import 'package:hive/hive.dart';

import '../models/product.dart';

class ProductLocalDataSource {
  ProductLocalDataSource({
    required Box productsBox,
    required Box favoritesBox,
  })  : _products = productsBox,
        _favorites = favoritesBox;

  final Box _products;
  final Box _favorites;

  Set<int> _deletedIds() {
    final raw = _products.get('__deleted_ids__', defaultValue: <int>[]);
    return (raw as List).map((value) => (value as num).toInt()).toSet();
  }

  List<Product> getCachedProducts() {
    return _products.keys
        .where((key) => key.toString() != '__deleted_ids__')
        .map((key) => _products.get(key))
        .whereType<Map>()
        .map((value) => Product.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> cachePage(List<Product> products) async {
    final deleted = _deletedIds();
    for (final product in products) {
      // Preserve local edits and local deletions when refreshing from the API.
      if (!deleted.contains(product.id) &&
          !_products.containsKey(product.id.toString())) {
        await _products.put(product.id.toString(), product.toJson());
      }
    }
  }

  Future<void> saveProduct(Product product) async {
    final deleted = _deletedIds()..remove(product.id);
    await _products.put('__deleted_ids__', deleted.toList());
    await _products.put(product.id.toString(), product.toJson());
  }

  Future<void> deleteProduct(int id) async {
    final deleted = _deletedIds()..add(id);
    await _products.put('__deleted_ids__', deleted.toList());
    await _products.delete(id.toString());
    await setFavorite(id, false);
  }

  bool isFavorite(int id) => _favorites.get(id.toString(), defaultValue: false) as bool;

  Future<void> setFavorite(int id, bool value) =>
      _favorites.put(id.toString(), value);

  Set<int> getFavoriteIds() => _favorites.keys
      .where((key) => _favorites.get(key, defaultValue: false) == true)
      .map((key) => int.tryParse(key.toString()))
      .whereType<int>()
      .toSet();
}
