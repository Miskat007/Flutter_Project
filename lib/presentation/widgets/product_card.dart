import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colors.surfaceContainerHighest,
                    child: product.thumbnail.isEmpty
                        ? const Icon(Icons.image_not_supported_outlined, size: 42)
                        : CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined, size: 38),
                          ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: colors.surface.withValues(alpha: .92),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : colors.onSurface,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .5,
                            )),
                    const SizedBox(height: 4),
                    Text(product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text('\$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                        ),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFFFB547)),
                        Text(product.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
