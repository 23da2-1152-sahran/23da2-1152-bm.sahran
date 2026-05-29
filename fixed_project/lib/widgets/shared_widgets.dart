import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../utils/image_url_resolver.dart';
import 'package:provider/provider.dart';

export 'product_card.dart';

/// Displays product images from bundled assets or Firebase Storage URLs.
/// ⚠️ NOTE: Use Firebase Storage URLs for best results.
/// External CDN URLs (like clothbase.com) may have hotlink protection.
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl.startsWith('http');
    final isFirebaseUrl = imageUrl.contains('firebasestorage.googleapis.com');
    const isWeb = kIsWeb;
    
    final placeholder = Container(
      color: AppTheme.cardBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, 
            color: AppTheme.textMuted, 
            size: 32),
          const SizedBox(height: 4),
          if (isNetworkImage && !isFirebaseUrl)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Use Firebase Storage URLs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );

    if (isNetworkImage) {
      // Apply CORS proxy for web platform to fix external image loading
      final resolvedUrl = ImageUrlResolver.resolveImageUrl(imageUrl);
      
      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: fit,
        placeholder: (context, url) => Container(
          color: AppTheme.cardBg,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('❌ Image load error for $imageUrl');
          debugPrint('   Resolved URL: $resolvedUrl');
          debugPrint('   Error: $error');
          debugPrint('   IsWeb: $isWeb');
          debugPrint('   IsFirebaseUrl: $isFirebaseUrl');
          
          // Try fallback without CORS proxy
          if (resolvedUrl.contains('images.weserv.nl') && !isFirebaseUrl) {
            return Image.network(
              imageUrl,
              fit: fit,
              errorBuilder: (_, __, ___) => placeholder,
            );
          }
          
          if (isWeb && !isFirebaseUrl) {
            debugPrint('   ⚠️ Web has CORS restrictions - using CORS proxy');
          }
          return placeholder;
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Asset load error for $imageUrl: $error');
        return placeholder;
      },
    );
  }
}

// ── Archive App Bar ──────────────────────────────────────────────────────────
class ArchiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? backLabel;
  final List<Widget>? actions;

  const ArchiveAppBar({
    super.key,
    this.showBack = false,
    this.backLabel,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: showBack ? 120 : 56,
      leading: showBack
          ? GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back,
                        size: 16, color: AppTheme.textPrimary),
                    if (backLabel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        backLabel!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            )
          : const Padding(
              padding: EdgeInsets.only(left: 24),
              child: Icon(Icons.menu, size: 18, color: AppTheme.textPrimary),
            ),
      title: const Text(
        'SENIOR',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 3.6,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: actions ??
          [
            Consumer<CartProvider>(
              builder: (ctx, cart, _) => Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: Icon(Icons.shopping_bag_outlined,
                        size: 20, color: AppTheme.textPrimary),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 18,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
    );
  }
}

// ── Archive Bottom Nav ───────────────────────────────────────────────────────
class ArchiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ArchiveBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  label: 'HOME',
                  index: 0,
                  current: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.grid_view_outlined,
                  label: 'EXPLORE',
                  index: 1,
                  current: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'CART',
                  index: 2,
                  current: currentIndex,
                  onTap: onTap),
              _NavItem(
                  icon: Icons.person_outline,
                  label: 'PROFILE',
                  index: 3,
                  current: currentIndex,
                  onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isActive ? AppTheme.textPrimary : AppTheme.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 1.5,
                color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label style helper ───────────────────────────────────────────────────────
TextStyle labelStyle({
  double size = 10,
  double spacing = 2.0,
  Color color = AppTheme.textSecondary,
  FontWeight weight = FontWeight.w500,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
    );
