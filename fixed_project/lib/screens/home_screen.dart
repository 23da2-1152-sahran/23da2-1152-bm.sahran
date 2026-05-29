import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/shared_widgets.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _HeroSection(),
            ),
            const SizedBox(height: 32),
            // Trending
            _TrendingSection(),
            const SizedBox(height: 32),
            // Newsletter Banner
            _NewsletterBanner(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      color: AppTheme.cardBg,
      child: Stack(
        children: [
          Image.asset(
            'assets/home_page_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppTheme.cardBg),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.overlayDark.withValues(alpha: 0.6),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          // Content
          Positioned(
            left: 32,
            right: 32,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SUMMER SENIOR 2024',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.0,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'THE NEW\nMINIMALISM.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textPrimary,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'EXPLORE COLLECTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingSection extends StatefulWidget {
  @override
  State<_TrendingSection> createState() => _TrendingSectionState();
}

class _TrendingSectionState extends State<_TrendingSection> {
  int _activeFilter = 0;
  final filters = ['All', 'New In', 'Outerwear', 'Accessories', 'Jackets'];

  List<Product> _filterProducts(List<Product> products) {
    switch (filters[_activeFilter]) {
      case 'New In':
        return products.take(4).toList();
      case 'Outerwear':
        return products
            .where((p) =>
                p.category == 'Outerwear' ||
                p.name.toLowerCase().contains('coat') ||
                p.name.toLowerCase().contains('trench'))
            .toList();
      case 'Accessories':
        return products
            .where((p) =>
                p.category == 'Accessories' || p.collection == 'ACCESSORIES')
            .toList();
      case 'Jackets':
        return products
            .where((p) =>
                p.category == 'Jackets' ||
                p.name.toLowerCase().contains('blazer'))
            .toList();
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRENDING NOW',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The season\'s most sought-after pieces.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Filter bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final active = i == _activeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.textPrimary : Colors.transparent,
                      border: Border.all(
                        color: active ? AppTheme.textPrimary : AppTheme.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filters[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: active ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Consumer<ProductProvider>(
          builder: (context, provider, _) {
            final products = _filterProducts(provider.allProducts);
            if (provider.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (provider.error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(provider.error!,
                    style: const TextStyle(color: AppTheme.textSecondary)),
              );
            }
            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('No products found.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.90,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NewsletterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(
          color: AppTheme.textPrimary,
        ),
        child: Column(
          children: [
            const Text(
              'THE SENIOR\nEDITORIAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Curated fashion insights, early access to new collections, and exclusive member offers delivered to your inbox.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  'SUBSCRIBE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
