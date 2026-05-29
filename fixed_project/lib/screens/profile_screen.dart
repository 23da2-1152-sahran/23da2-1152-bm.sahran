import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../app_state.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/shared_widgets.dart';
import 'order_history_screen.dart';
import 'product_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppTheme.cardBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppTheme.background,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 16, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final profile = auth.userProfile;
                        final displayName = profile?.displayName ??
                            auth.currentUser?.displayName ??
                            'SENIOR MEMBER';
                        final email =
                            profile?.email ?? auth.currentUser?.email ?? '';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase().replaceAll(' ', '\n'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: AppTheme.textPrimary,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  color: AppTheme.textPrimary,
                                  child: const Text(
                                    'SENIOR MEMBER',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.accent),
                                  ),
                                  child: const Text(
                                    'GOLD TIER',
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
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Bento grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Order History Card
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                        color: AppTheme.cardBg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<OrderProvider>(
                            builder: (context, orders, _) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.receipt_long_outlined,
                                        size: 20, color: AppTheme.textPrimary),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Order History',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${orders.orders.length} orders placed.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward,
                                    size: 16, color: AppTheme.textPrimary),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Recent thumbnails
                          Consumer<OrderProvider>(
                            builder: (context, orders, _) {
                              final recentItems = orders.orders
                                  .expand((order) => order.items)
                                  .take(3)
                                  .toList();

                              if (recentItems.isEmpty) {
                                return const Text(
                                  'No orders yet.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }

                              return Row(
                                children: recentItems.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppTheme.background, width: 2),
                                    ),
                                    child:
                                        ProductImage(imageUrl: item.imageUrl),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Saved items
                  Consumer<AppState>(
                    builder: (ctx, state, _) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bookmark_border,
                              size: 16, color: AppTheme.textPrimary),
                          const SizedBox(height: 12),
                          const Text(
                            'Saved Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.savedItems.length} items curated.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.savedItems.isNotEmpty)
                            Consumer<ProductProvider>(
                              builder: (context, products, _) {
                                final savedProducts = products.allProducts
                                    .where(
                                        (p) => state.savedItems.contains(p.id))
                                    .toList();

                                return SizedBox(
                                  height: 80,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: savedProducts
                                        .map(
                                          (p) => Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            width: 64,
                                            color: AppTheme.cardBg,
                                            child: ProductImage(
                                                imageUrl: p.imageUrl),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                );
                              },
                            )
                          else
                            const Text(
                              'No saved items yet.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Settings
                  ...[
                    ('Settings', Icons.settings_outlined),
                    ('Notifications', Icons.notifications_outlined),
                    ('Log Out', Icons.logout_outlined),
                  ].map(
                    (item) => Column(
                      children: [
                        GestureDetector(
                          onTap: item.$1 == 'Log Out'
                              ? () async {
                                  await context.read<AuthProvider>().logout();
                                  if (!context.mounted) return;
                                  context.read<CartProvider>().reset();
                                  context.read<OrderProvider>().reset();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              : item.$1 == 'Settings'
                                  ? () => _showProfileEditor(context)
                                  : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: AppTheme.border)),
                            ),
                            child: Row(
                              children: [
                                Icon(item.$2,
                                    size: 18, color: AppTheme.textPrimary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    size: 16, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Recently Viewed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recently Viewed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<ProductProvider>(
                    builder: (context, products, _) {
                      final recentProducts =
                          products.allProducts.take(4).toList();

                      if (recentProducts.isEmpty) {
                        return const Text(
                          'No products loaded yet.',
                          style: TextStyle(color: AppTheme.textMuted),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: recentProducts.length,
                        itemBuilder: (context, index) {
                          final product = recentProducts[index];
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
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showProfileEditor(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final profile = auth.userProfile;
    final nameCtrl = TextEditingController(text: profile?.displayName ?? '');
    final phoneCtrl = TextEditingController(text: profile?.phoneNumber ?? '');
    final addressCtrl =
        TextEditingController(text: profile?.shippingAddress ?? '');
    final cityCtrl = TextEditingController(text: profile?.city ?? '');
    final postalCtrl = TextEditingController(text: profile?.postalCode ?? '');
    final countryCtrl = TextEditingController(text: profile?.country ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _profileField('FULL NAME', nameCtrl),
              _profileField('PHONE', phoneCtrl),
              _profileField('ADDRESS', addressCtrl),
              _profileField('CITY', cityCtrl),
              _profileField('POSTAL CODE', postalCtrl),
              _profileField('COUNTRY', countryCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await auth.updateUserProfile(
                      displayName: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      shippingAddress: addressCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                      postalCode: postalCtrl.text.trim(),
                      country: countryCtrl.text.trim(),
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Profile updated.'
                            : auth.error ?? 'Could not update profile.'),
                      ),
                    );
                  },
                  child: const Text(
                    'SAVE PROFILE',
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
      ),
    );
  }

  Widget _profileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle(size: 9, spacing: 2.0)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
