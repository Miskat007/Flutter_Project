import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<ProductProvider>().search(value);
    });
  }

  Future<void> _openForm({Product? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final items = provider.visibleProducts
            .where((p) => !_favoritesOnly || provider.isFavorite(p))
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOVA STORE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        )),
                Text('Find your next favorite',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Toggle theme',
                icon: Icon(Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: () {
                  final box = Hive.box('app_settings');
                  box.put('darkMode',
                      Theme.of(context).brightness != Brightness.dark);
                },
              ),
              IconButton(
                tooltip: 'Favorites',
                icon: Icon(_favoritesOnly ? Icons.favorite : Icons.favorite_border),
                onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
              ),
              const SizedBox(width: 6),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
          body: RefreshIndicator(
            onRefresh: provider.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 280) {
                  provider.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('GOOD FINDS,\\nBETTER DAYS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 21,
                                            height: 1.15,
                                          )),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${provider.total} products to explore',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.local_mall_outlined,
                                    color: Colors.white, size: 58),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearch,
                            decoration: InputDecoration(
                              hintText: 'Search products, brands, categories...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.search('');
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(_favoritesOnly ? 'Your favorites' : 'Popular products',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (provider.isOffline)
                                const Chip(
                                  avatar: Icon(Icons.cloud_off, size: 16),
                                  label: Text('Offline'),
                                ),
                            ],
                          ),
                          if (provider.errorMessage != null &&
                              !provider.isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(provider.errorMessage!,
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.error)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.isLoading && provider.products.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        message: _favoritesOnly
                            ? 'No favorites yet'
                            : 'No products found',
                        onRetry: provider.refresh,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          final count = width > 900 ? 4 : width > 600 ? 3 : 2;
                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: count,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: width > 600 ? .72 : .64,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = items[index];
                                return ProductCard(
                                  product: product,
                                  isFavorite: provider.isFavorite(product),
                                  onFavorite: () => provider.toggleFavorite(product),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                          product: product),
                                    ),
                                  ),
                                );
                              },
                              childCount: items.length,
                            ),
                          );
                        },
                      ),
                    ),
                  if (provider.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 54),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      );
}
