import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';
import 'product_listing_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ProductListingScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrapProviders);
  }

  Future<void> _bootstrapProviders() async {
    if (!mounted || _didBootstrap) return;
    _didBootstrap = true;

    final auth = context.read<AuthProvider>();
    final products = context.read<ProductProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final userId = auth.currentUser?.uid;

    await products.fetchProducts();
    if (!mounted || userId == null) return;

    orders.setUserId(userId);
    await Future.wait([
      cart.initializeCart(userId),
      orders.fetchOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) => Scaffold(
        body: IndexedStack(
          index: state.currentNavIndex,
          children: MainShell._screens,
        ),
        bottomNavigationBar: ArchiveBottomNav(
          currentIndex: state.currentNavIndex,
          onTap: state.setNavIndex,
        ),
      ),
    );
  }
}
