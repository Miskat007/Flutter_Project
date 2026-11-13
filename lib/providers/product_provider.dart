import 'package:flutter/foundation.dart';

import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;
  static const int pageSize = 20;

  final List<Product> _products = [];
  Set<int> _favoriteIds = {};
  int _total = 0;
  int _skip = 0;
  String _query = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _isOffline = false;
  String? _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _products.length < _total;

  List<Product> get visibleProducts {
    if (_query.isEmpty) return products;
    final q = _query.toLowerCase();
    return _products.where((p) =>
      p.title.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q) ||
      p.brand.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> loadInitial() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _repository.getPage(limit: pageSize, skip: 0);
      _products
        ..clear()
        ..addAll(page.products);
      _total = page.total;
      _skip = page.products.length;
      _isOffline = false;
    } catch (error) {
      _hasError = true;
      _errorMessage = 'Could not connect. Showing saved products.';
      _isOffline = true;
      _products
        ..clear()
        ..addAll(_repository.getCachedProducts());
      _total = _products.length;
      if (_products.isEmpty) {
        _errorMessage = 'No saved products yet. Connect to the internet and retry.';
      }
    } finally {
      _favoriteIds = _repository.getFavoriteIds();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _skip = 0;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !hasMore || _isOffline) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.getPage(
        limit: pageSize,
        skip: _skip,
        query: _query,
      );
      _mergeProducts(page.products);
      _total = page.total;
      _skip += page.products.length;
    } catch (_) {
      _errorMessage = 'Could not load more products. Check your connection.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> search(String value) async {
    _query = value.trim();
    _skip = 0;
    _isLoading = true;
    notifyListeners();
    try {
      final page = await _repository.getPage(
        limit: pageSize,
        skip: 0,
        query: _query,
      );
      _products
        ..clear()
        ..addAll(page.products);
      _total = page.total;
      _skip = page.products.length;
      _isOffline = false;
      _hasError = false;
    } catch (_) {
      _isOffline = true;
      final cached = _repository.getCachedProducts();
      _products
        ..clear()
        ..addAll(cached.where((p) =>
          p.title.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase())));
      _total = _products.length;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mergeProducts(List<Product> incoming) {
    for (final product in incoming) {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index == -1) {
        _products.add(product);
      } else if (!_products[index].isLocal) {
        _products[index] = product;
      }
    }
  }

  Future<void> saveProduct(Product product, {required bool isNew}) async {
    final saved = isNew
        ? await _repository.create(product)
        : await _repository.update(product);
    final index = _products.indexWhere((p) => p.id == saved.id);
    if (index == -1) {
      _products.insert(0, saved);
      _total++;
    } else {
      _products[index] = saved;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(Product product) async {
    await _repository.delete(product.id);
    _products.removeWhere((p) => p.id == product.id);
    _favoriteIds.remove(product.id);
    if (_total > 0) _total--;
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    final next = !_favoriteIds.contains(product.id);
    await _repository.setFavorite(product.id, next);
    if (next) {
      _favoriteIds.add(product.id);
    } else {
      _favoriteIds.remove(product.id);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) => _favoriteIds.contains(product.id);
}
