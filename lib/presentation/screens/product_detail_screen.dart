import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final favorite = provider.isFavorite(product);
    final current = provider.products.where((p) => p.id == product.id);
    final item = current.isEmpty ? product : current.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            onPressed: () => provider.toggleFavorite(item),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: item),
                  ),
                );
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete product?'),
                    content: Text('Remove "${item.title}" from this device?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await provider.deleteProduct(item);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.thumbnail.isEmpty
                ? const Icon(Icons.image_outlined, size: 70)
                : CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 60),
                  ),
          ),
          const SizedBox(height: 20),
          Text(item.category.toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(item.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  )),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('\$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      )),
              const SizedBox(width: 14),
              const Icon(Icons.star_rounded, color: Color(0xFFFFB547)),
              Text('${item.rating.toStringAsFixed(1)} rating'),
            ],
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Brand', value: item.brand.isEmpty ? 'Not specified' : item.brand),
          _InfoRow(label: 'Stock', value: '${item.stock} units'),
          _InfoRow(label: 'Product ID', value: item.id.toString()),
          _InfoRow(label: 'Storage', value: item.isLocal ? 'Saved locally' : 'API product'),
          const SizedBox(height: 18),
          Text('About this product',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          Text(item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
          if (item.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('More images',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 10),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: item.images[index],
                    width: 115,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const SizedBox(width: 115, child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 105,
              child: Text(label,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
