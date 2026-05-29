import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../widgets/shared_widgets.dart';
import '../app_state.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColorIndex = 0;
  String _selectedSize = '';
  bool _descExpanded = false;
  final int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: ArchiveAppBar(
        showBack: true,
        backLabel: 'BACK',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<AppState>(
              builder: (ctx, state, _) => GestureDetector(
                onTap: () => state.toggleSaved(product.id),
                child: Icon(
                  state.isSaved(product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 20,
                  color: state.isSaved(product.id)
                      ? AppTheme.accent
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Icon(Icons.shopping_bag_outlined,
                size: 20, color: AppTheme.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main gallery
            Stack(
              children: [
                Container(
                  height: 420,
                  width: double.infinity,
                  color: AppTheme.cardBg,
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
                // Indicator dots
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _galleryIndex ? 24 : 6,
                        height: 3,
                        color: i == _galleryIndex
                            ? AppTheme.background
                            : AppTheme.background.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Thumbnails
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: AppTheme.cardBg,
                        child: ProductImage(imageUrl: product.imageUrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: const Color(0xFFEEECE8),
                        child: ProductImage(imageUrl: product.imageUrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.collection,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppTheme.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'LKR${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        color: AppTheme.accentLight,
                        child: const Text(
                          'FREE SHIPPING',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  if (product.description.isNotEmpty) ...[
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.7,
                      ),
                      maxLines: _descExpanded ? null : 3,
                      overflow: _descExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _descExpanded = !_descExpanded),
                      child: Text(
                        _descExpanded ? 'Read less ↑' : 'Read more ↓',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Color Selection
                  if (product.colors.isNotEmpty) ...[
                    const Text(
                      'SELECT COLOR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(
                        product.colors.length,
                        (i) => GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _colorFromName(product.colors[i]),
                              border: Border.all(
                                color: i == _selectedColorIndex
                                    ? AppTheme.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.colors[_selectedColorIndex],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  // Size Selection
                  if (product.sizes.isNotEmpty) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SELECT SIZE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'SIZE GUIDE →',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: AppTheme.accent,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.sizes.map((size) {
                        final active = size == _selectedSize;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            width: 72,
                            height: 44,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.textPrimary
                                  : Colors.transparent,
                              border: Border.all(
                                color: active
                                    ? AppTheme.textPrimary
                                    : AppTheme.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // CTA Buttons
                  Consumer2<CartProvider, AppState>(
                    builder: (ctx, cart, state, _) => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: product.isInStock
                                ? () {
                                    cart.addToCart(
                                      product,
                                      product.colors.isNotEmpty
                                          ? product.colors[_selectedColorIndex]
                                          : '',
                                      _selectedSize,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Added to cart',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white),
                                        ),
                                        backgroundColor: AppTheme.textPrimary,
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                : null,
                            child: Text(
                              product.isInStock
                                  ? 'ADD TO CART'
                                  : 'OUT OF STOCK',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: OutlinedButton.icon(
                            onPressed: () => state.toggleSaved(product.id),
                            icon: Icon(
                              state.isSaved(product.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                            ),
                            label: Text(
                              state.isSaved(product.id)
                                  ? 'SAVED TO WISHLIST'
                                  : 'ADD TO WISHLIST',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Delivery Info
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: AppTheme.cardBg,
                          child: const Column(
                            children: [
                              Icon(Icons.local_shipping_outlined,
                                  size: 20, color: AppTheme.textSecondary),
                              SizedBox(height: 8),
                              Text(
                                'Free Delivery',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: AppTheme.cardBg,
                          child: const Column(
                            children: [
                              Icon(Icons.refresh_outlined,
                                  size: 20, color: AppTheme.textSecondary),
                              SizedBox(height: 8),
                              Text(
                                'Easy Returns',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Related products
                  const Text(
                    'YOU MAY\nALSO LIKE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...context
                      .watch<ProductProvider>()
                      .allProducts
                      .where((p) => p.id != product.id)
                      .take(3)
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: p),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 96,
                                  color: AppTheme.cardBg,
                                  child: ProductImage(imageUrl: p.imageUrl),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p.subtitle,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LKR${p.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'noir':
      case 'charcoal':
      case 'black':
        return const Color(0xFF2D2D2D);
      case 'ivory':
      case 'ivory white':
        return const Color(0xFFF8F5EF);
      case 'camel':
      case 'oat':
      case 'oatmeal':
      case 'oatmeal melange':
        return const Color(0xFFD4A96A);
      case 'cognac':
        return const Color(0xFF9A5C2C);
      case 'smoke':
        return const Color(0xFF9BA0A2);
      case 'ecru':
        return const Color(0xFFEDEADE);
      case 'navy':
        return const Color(0xFF1C2B4B);
      default:
        return AppTheme.textMuted;
    }
  }
}
