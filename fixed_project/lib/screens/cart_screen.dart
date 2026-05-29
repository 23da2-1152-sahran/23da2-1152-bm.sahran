import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../app_state.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/shared_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.cart.isEmpty) {
            return _EmptyCart();
          }
          return _CartContent(cart: cart);
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 24),
          const Text(
            'YOUR CART IS EMPTY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover our curated collection',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).setNavIndex(1);
            },
            child: const Text(
              'EXPLORE COLLECTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartContent extends StatefulWidget {
  final CartProvider cart;

  // ignore: prefer_const_constructors_in_immutables
  _CartContent({required this.cart});

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  final TextEditingController _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'CART',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'SELECTION OF CURATED ESSENTIALS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 32),
                // Items
                ...cart.cart
                    .map((item) => _CartItemRow(item: item, cart: cart)),
                const SizedBox(height: 24),
                // Promo code
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCtrl,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.0,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'PROMO CODE',
                          hintStyle: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2.0,
                            color: AppTheme.textMuted,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      color: AppTheme.textPrimary,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'APPLY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Summary
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: AppTheme.cardBg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER SUMMARY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SummaryRow(
                        label: 'Subtotal',
                        value: 'LKR${cart.subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Shipping',
                        value: cart.subtotal > 0 ? 'LKR15.00' : 'FREE',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Tax',
                        value: 'LKR${cart.tax.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'LKR${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Checkout CTA
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                child: const Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;

  // ignore: prefer_const_constructors_in_immutables
  _CartItemRow({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 128,
            color: AppTheme.cardBg,
            child: ProductImage(imageUrl: item.product.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeFromCart(item),
                      child: const Icon(Icons.close,
                          size: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.selectedColor} / ${item.selectedSize}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity control
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.updateQuantity(item, -1),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove,
                                  size: 14, color: AppTheme.textPrimary),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cart.updateQuantity(item, 1),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add,
                                  size: 14, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LKR${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
