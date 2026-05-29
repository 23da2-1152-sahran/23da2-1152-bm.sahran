import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../app_state.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/image_url_resolver.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppTheme.cardBg,
                      child: _ProductCardImage(imageUrl: product.image),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Consumer<AppState>(
                      builder: (context, state, _) {
                        final saved = state.isSaved(product.id);
                        return GestureDetector(
                          onTap: () => state.toggleSaved(product.id),
                          child: Container(
                            width: 34,
                            height: 34,
                            color: AppTheme.background.withValues(alpha: 0.92),
                            child: Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              size: 17,
                              color: saved
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!product.isInStock)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        color: AppTheme.textPrimary,
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.6,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LKR${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  final String imageUrl;

  const _ProductCardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppTheme.cardBg,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.textMuted),
      ),
    );

    if (imageUrl.isEmpty) return placeholder;

    if (imageUrl.startsWith('http')) {
      // Resolve URL with CORS proxy for web platform
      final resolvedUrl = ImageUrlResolver.resolveImageUrl(imageUrl);

      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) {
          // Try fallback without CORS proxy
          if (resolvedUrl.contains('images.weserv.nl')) {
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            );
          }
          return placeholder;
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
