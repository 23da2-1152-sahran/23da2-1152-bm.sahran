## Firebase Provider Integration Examples

This guide shows how to integrate the new Firebase providers with your existing screens while maintaining your current UI.

---

## 1. Login Screen Integration

Update your `LoginScreen` to use `AuthProvider`:

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';

class _LoginScreenState extends State<LoginScreen> {
  // ... existing code ...

  void _handleLogin() async {
    if (!_validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    // Get AuthProvider
    final authProvider = context.read<AuthProvider>();
    
    // Attempt login
    final success = await authProvider.login(email, password);

    if (success && mounted) {
      // Initialize other providers with user ID
      final userId = authProvider.currentUser!.uid;
      
      // Initialize cart
      context.read<CartProvider>().initializeCart(userId);
      
      // Initialize orders
      context.read<OrderProvider>().setUserId(userId);
      context.read<OrderProvider>().fetchOrders();
      
      // Initialize products
      context.read<ProductProvider>().fetchProducts();

      // Navigate to home
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );
    } else if (mounted) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing UI code ...
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            // Your existing UI, just add loading state:
            child: Stack(
              children: [
                // Your existing login form widgets...
                
                // Add loading overlay if needed
                if (authProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 2. Register Screen Integration

Update your `RegisterScreen` to use `AuthProvider`:

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  // ... other controllers ...

  void _handleRegister() async {
    if (!_validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final name = _nameCtrl.text.trim();

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.register(email, password, name);

    if (success && mounted) {
      // Initialize providers
      final userId = authProvider.currentUser!.uid;
      context.read<CartProvider>().initializeCart(userId);
      context.read<OrderProvider>().setUserId(userId);
      context.read<ProductProvider>().fetchProducts();

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          // Your existing register UI with loading state
        );
      },
    );
  }
}
```

---

## 3. Home Screen Integration

Update `HomeScreen` to fetch products from Firestore:

```dart
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(child: Text('Error: ${productProvider.error}'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _HeroSection(),
                ),
                const SizedBox(height: 32),
                
                // Use Firestore products instead of demo products
                _TrendingSection(products: productProvider.filteredProducts),
                
                const SizedBox(height: 32),
                _NewsletterBanner(),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Update _TrendingSection to accept products
class _TrendingSection extends StatelessWidget {
  final List<Product> products;

  const _TrendingSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TRENDING NOW', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/products'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: products[index]),
                  ),
                ),
                child: ProductCard(product: products[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 4. Product Listing Screen Integration

```dart
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(title: 'Products'),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Category Filter
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: productProvider.categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final category = productProvider.categories[i];
                    final isActive = category == productProvider.selectedCategory;
                    return GestureDetector(
                      onTap: () => productProvider.filterByCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.accent : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Products Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: productProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.filteredProducts[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      ),
                      child: ProductGridItem(product: product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 5. Cart Screen Integration

```dart
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(title: 'Cart'),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cart.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cart[index];
                    return CartItemWidget(
                      item: item,
                      onQuantityChanged: (newQty) {
                        cartProvider.updateQuantity(item, newQty);
                      },
                      onRemove: () {
                        cartProvider.removeFromCart(item);
                      },
                    );
                  },
                ),
              ),
              
              // Cart Summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  border: Border(
                    top: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax (10%)'),
                        Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping'),
                        Text('\$${cartProvider.shipping.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '\$${cartProvider.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/checkout'),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 6. Checkout Screen Integration

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  
  void _placeOrder() async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place order')),
      );
      return;
    }

    // Create order from cart
    final orderItems = cartProvider.cart.map((item) {
      return OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        price: item.product.price,
        imageUrl: item.product.imageUrl,
        selectedColor: item.selectedColor,
        selectedSize: item.selectedSize,
        quantity: item.quantity,
      );
    }).toList();

    final order = Order(
      id: '', // Will be set by Firestore
      userId: authProvider.currentUser!.uid,
      items: orderItems,
      subtotal: cartProvider.subtotal,
      tax: cartProvider.tax,
      shipping: cartProvider.shipping,
      total: cartProvider.total,
      createdAt: DateTime.now(),
      shippingAddress: _addressCtrl.text,
    );

    // Create order in Firestore
    final orderId = await orderProvider.createOrder(order);

    if (orderId != null && mounted) {
      // Clear cart after successful order
      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate to order confirmation
      Navigator.pushNamed(
        context,
        '/order-confirmation',
        arguments: orderId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(title: 'Checkout'),
      body: Consumer2<CartProvider, OrderProvider>(
        builder: (context, cartProvider, orderProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address
                  TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Shipping Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax:'),
                            Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Shipping:'),
                            Text('\$${cartProvider.shipping.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '\$${cartProvider.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: orderProvider.isLoading ? null : _placeOrder,
                      child: orderProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }
}
```

---

## 7. Profile Screen Integration

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    
    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userProfile != null) {
        _nameCtrl.text = authProvider.userProfile!.displayName ?? '';
        _phoneCtrl.text = authProvider.userProfile!.phoneNumber ?? '';
        _addressCtrl.text = authProvider.userProfile!.shippingAddress ?? '';
      }
    });
  }

  void _updateProfile() async {
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.updateUserProfile(
      displayName: _nameCtrl.text,
      phoneNumber: _phoneCtrl.text,
      shippingAddress: _addressCtrl.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const ArchiveAppBar(title: 'Profile'),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.currentUser?.email ?? 'Guest',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                // Name Field
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Address Field
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Shipping Address',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _updateProfile,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Update Profile'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }
}
```

---

## Summary

These examples show how to:
- ✅ Fetch data from Firestore using Providers
- ✅ Handle user authentication
- ✅ Manage cart with persistence
- ✅ Create and track orders
- ✅ Update user profiles
- ✅ Display loading and error states
- ✅ Maintain your existing UI design

All provider operations are non-blocking and reactive thanks to Flutter's Provider pattern.
