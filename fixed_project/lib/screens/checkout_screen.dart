import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../app_state.dart';
import '../models/order.dart' as models;
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/shared_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _paymentMethod = 0; // 0 = card, 1 = paypal

  final _nameCtrl = TextEditingController(text: 'Julianne Moore');
  final _addressCtrl =
      TextEditingController(text: '1248 North Boulevard, Suite 400');
  final _cityCtrl = TextEditingController(text: 'New York');
  final _zipCtrl = TextEditingController(text: '10001');
  final _cardCtrl = TextEditingController(text: '0000 0000 0000 0000');
  final _expiryCtrl = TextEditingController(text: 'MM / YY');
  final _cvvCtrl = TextEditingController(text: '***');
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back,
              size: 16, color: AppTheme.textPrimary),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Breadcrumb
            Row(
              children: [
                _breadcrumb('Cart', muted: true),
                _chevron(),
                _breadcrumb('Shipping', muted: true),
                _chevron(),
                _breadcrumb('Payment'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Finalize Your Order',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            // Section 1: Shipping
            _sectionHeader('1', 'SHIPPING DETAILS'),
            const SizedBox(height: 24),
            _formField('FULL NAME', _nameCtrl),
            const SizedBox(height: 16),
            _formField('STREET ADDRESS', _addressCtrl),
            const SizedBox(height: 16),
            _formField('CITY', _cityCtrl),
            const SizedBox(height: 16),
            _formField('POSTAL CODE', _zipCtrl, type: TextInputType.number),
            const SizedBox(height: 40),
            // Section 2: Payment
            _sectionHeader('2', 'PAYMENT METHOD'),
            const SizedBox(height: 16),
            // Payment options
            _paymentOption(
                0, 'Credit Card', Icons.credit_card, 'Visa, Mastercard, Amex'),
            const SizedBox(height: 8),
            _paymentOption(
                1, 'PayPal', Icons.paypal, 'Pay securely via PayPal'),
            if (_paymentMethod == 0) ...[
              const SizedBox(height: 24),
              _formField('CARD NUMBER', _cardCtrl, type: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _formField('EXPIRY DATE', _expiryCtrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _formField('CVV', _cvvCtrl,
                        type: TextInputType.number, obscure: true),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
            // Order Summary
            Consumer<CartProvider>(
              builder: (ctx, cart, _) => Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...cart.cart.take(2).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 80,
                                  color: AppTheme.cardBg,
                                  child: ProductImage(
                                      imageUrl: item.product.imageUrl),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.selectedColor} / ${item.selectedSize}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'LKR${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 12),
                    _summaryRow(
                        'Subtotal', 'LKR${cart.subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _summaryRow(
                        'Shipping', 'LKR${cart.shipping.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _summaryRow('Tax', 'LKR${cart.tax.toStringAsFixed(2)}'),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : () => _placeOrder(context),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'PLACE ORDER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '🔒 Secured by SSL encryption. Your data is protected.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _breadcrumb(String label, {bool muted = false}) => Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
          color: muted ? AppTheme.textMuted : AppTheme.textPrimary,
        ),
      );

  Widget _chevron() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.chevron_right, size: 14, color: AppTheme.textMuted),
      );

  Widget _sectionHeader(String num, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          color: AppTheme.textPrimary,
          alignment: Alignment.center,
          child: Text(
            num,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {TextInputType? type, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _paymentOption(int index, String label, IconData icon, String sub) {
    final active = index == _paymentMethod;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? AppTheme.textPrimary : AppTheme.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppTheme.textPrimary : AppTheme.border,
                  width: active ? 4 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
        ],
      );

  Future<void> _placeOrder(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final user = auth.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (cart.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final order = models.Order(
      id: '',
      userId: user.uid,
      items: cart.cart
          .map(
            (item) => models.OrderItem(
              productId: item.product.id,
              productName: item.product.name,
              price: item.product.price,
              imageUrl: item.product.imageUrl,
              selectedColor: item.selectedColor,
              selectedSize: item.selectedSize,
              quantity: item.quantity,
            ),
          )
          .toList(),
      subtotal: cart.subtotal,
      tax: cart.tax,
      shipping: cart.shipping,
      total: cart.total,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      shippingAddress:
          '${_nameCtrl.text.trim()}, ${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()} ${_zipCtrl.text.trim()}',
    );

    final orderId = await orders.createOrder(order);
    if (!context.mounted) return;
    setState(() => _isPlacingOrder = false);

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'Could not place order.')),
      );
      return;
    }

    await cart.clearCart();
    if (!context.mounted) return;
    _showConfirmation(context, orderId);
  }

  void _showConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: AppTheme.background,
        title: const Text(
          'Order Confirmed!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Your order $orderId has been placed successfully. You will receive a confirmation email shortly.',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Provider.of<AppState>(context, listen: false).setNavIndex(1);
            },
            child: const Text(
              'CONTINUE SHOPPING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
