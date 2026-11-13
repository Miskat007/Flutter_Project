import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository({required this.remote, required this.local});

  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;

  Future<ProductPage> getPage({
    required int limit,
    required int skip,
    String query = '',
  }) async {
    final page = await remote.getProducts(
      limit: limit,
      skip: skip,
      query: query,
    );
    await local.cachePage(page.products);
    return page;
  }

  List<Product> getCachedProducts() => local.getCachedProducts();

  Future<Product> create(Product draft) async {
    Product saved;
    try {
      // DummyJSON returns a simulated response; it does not persist server-side.
      saved = await remote.addProduct(draft);
    } catch (_) {
      saved = draft.copyWith(
        id: DateTime.now().microsecondsSinceEpoch * -1,
        isLocal: true,
      );
    }
    saved = saved.copyWith(isLocal: true);
    await local.saveProduct(saved);
    return saved;
  }

  Future<Product> update(Product product) async {
    try {
      await remote.updateProduct(product);
    } catch (_) {
      // Local update remains available offline.
    }
    final saved = product.copyWith(isLocal: true);
    await local.saveProduct(saved);
    return saved;
  }

  Future<void> delete(int id) async {
    try {
      await remote.deleteProduct(id);
    } catch (_) {
      // Local deletion is still applied if the device is offline.
    }
    await local.deleteProduct(id);
  }

  bool isFavorite(int id) => local.isFavorite(id);
  Future<void> setFavorite(int id, bool value) => local.setFavorite(id, value);
  Set<int> getFavoriteIds() => local.getFavoriteIds();
}
