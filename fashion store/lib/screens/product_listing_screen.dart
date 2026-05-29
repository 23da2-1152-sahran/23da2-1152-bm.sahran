import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/shared_widgets.dart';
import 'product_detail_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _activeFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final filters = [
    'All',
    'New In',
    'Outerwear',
    'Accessories',
    'Jackets',
    'Bags'
  ];

  List<Product> get filteredProducts {
    final products = context.read<ProductProvider>().allProducts;
    late final List<Product> categoryProducts;

    switch (filters[_activeFilter]) {
      case 'New In':
        categoryProducts = products
            .where((p) => p.badge == 'NEW' || p.collection == 'NEW ARRIVALS')
            .toList();
        break;
      case 'Outerwear':
        categoryProducts = products
            .where((p) =>
                p.category == 'Outerwear' ||
                p.name.toLowerCase().contains('coat') ||
                p.name.toLowerCase().contains('trench'))
            .toList();
        break;
      case 'Accessories':
        categoryProducts = products
            .where((p) =>
                p.category == 'Accessories' || p.collection == 'ACCESSORIES')
            .toList();
        break;
      case 'Jackets':
        categoryProducts = products
            .where((p) =>
                p.category == 'Jackets' ||
                p.name.toLowerCase().contains('blazer'))
            .toList();
        break;
      case 'Bags':
        categoryProducts = products
            .where((p) =>
                p.category == 'Bags' || p.name.toLowerCase().contains('bag'))
            .toList();
        break;
      default:
        categoryProducts = products;
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return categoryProducts;

    return categoryProducts.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.collection.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          (product.badge?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = filteredProducts;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: const ArchiveAppBar(),
          body: CustomScrollView(
            slivers: [
              // Hero masthead
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasonal\nCuration',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppTheme.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Exploring the intersection of architectural form and wearable silhouettes.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Filter bar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filters.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final active = i == _activeFilter;
                              return GestureDetector(
                                onTap: () => setState(() => _activeFilter = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                    filters[i],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.0,
                                      color: active
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.grid_view_rounded,
                                size: 16, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.view_list_outlined,
                                size: 16, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search pieces',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (provider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else ...[
                // Asymmetric Product Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.90,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
                // Load more
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            AppTheme.accent.withValues(alpha: 0.4),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'LOAD MORE PIECES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: AppTheme.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
