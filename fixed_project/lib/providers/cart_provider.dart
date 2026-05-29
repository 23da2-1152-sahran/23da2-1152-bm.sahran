import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart' as cart_models;
import '../services/firestore_service.dart';

/// CartProvider manages shopping cart state
/// Handles adding/removing items, quantity updates, and cart persistence in Firestore
class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<cart_models.CartItem> _cart = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  bool _hasLoadedCart = false;

  // Getters
  List<cart_models.CartItem> get cart => List.unmodifiable(_cart);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cart.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Calculate cart subtotal
  double get subtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  /// Calculate tax (10%)
  double get tax => subtotal * 0.1;

  /// Calculate shipping
  double get shipping => subtotal > 0 ? 15.0 : 0.0;

  /// Calculate total
  double get total => subtotal + tax + shipping;

  /// Initialize cart for user
  Future<void> initializeCart(String userId) async {
    if (_userId == userId && _hasLoadedCart) return;
    _userId = userId;
    _hasLoadedCart = false;
    await loadCart();
  }

  /// Clear local cart when the user logs out
  void reset() {
    _userId = null;
    _cart = [];
    _error = null;
    _hasLoadedCart = false;
    notifyListeners();
  }

  /// Load cart from Firestore
  Future<void> loadCart() async {
    if (_userId == null) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedItems = await _firestoreService.fetchCart(_userId!);
      final loadedCart = <cart_models.CartItem>[];

      for (final itemData in savedItems) {
        final productId = itemData['productId'] as String?;
        if (productId == null) continue;

        // Cart documents only store the selected options and product ID.
        // Fetching the product keeps price/image/name fresh from Firestore.
        final product = await _firestoreService.fetchProductById(productId);
        if (product == null) continue;

        loadedCart.add(cart_models.CartItem.fromMap(itemData, product));
      }

      _cart = loadedCart;
      _error = null;
      _hasLoadedCart = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add item to cart
  Future<void> addToCart(Product product, String color, String size) async {
    // Check if item already exists
    final existingItemIndex = _cart.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedColor == color &&
        item.selectedSize == size);

    if (existingItemIndex != -1) {
      // Increment quantity
      _cart[existingItemIndex].quantity++;
    } else {
      // Add new item
      _cart.add(cart_models.CartItem(
        product: product,
        selectedColor: color,
        selectedSize: size,
        quantity: 1,
      ));
    }

    notifyListeners();
    await _saveCart();
  }

  /// Remove item from cart
  Future<void> removeFromCart(cart_models.CartItem item) async {
    _cart.remove(item);
    notifyListeners();
    await _saveCart();
  }

  /// Change item quantity by a plus/minus amount from the UI.
  Future<void> updateQuantity(cart_models.CartItem item, int delta) async {
    final newQuantity = item.quantity + delta;
    if (newQuantity <= 0) {
      await removeFromCart(item);
      return;
    }

    final index = _cart.indexOf(item);
    if (index != -1) {
      _cart[index].quantity = newQuantity.clamp(1, 99);
      notifyListeners();
      await _saveCart();
    }
  }

  /// Set item quantity directly when another screen needs an exact value.
  Future<void> setQuantity(cart_models.CartItem item, int newQuantity) async {
    final index = _cart.indexOf(item);
    if (index == -1) return;

    if (newQuantity <= 0) {
      await removeFromCart(item);
      return;
    }

    _cart[index].quantity = newQuantity.clamp(1, 99);
    notifyListeners();
    await _saveCart();
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();
    await _clearCartFirebase();
  }

  /// Save cart to Firestore (for persistence)
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final cartData = _cart.map((item) => item.toMap()).toList();
      await _firestoreService.saveCart(_userId!, cartData);
      _hasLoadedCart = true;
    } catch (e) {
      debugPrint('Error saving cart: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear cart in Firestore
  Future<void> _clearCartFirebase() async {
    if (_userId == null) return;

    try {
      await _firestoreService.clearCart(_userId!);
      _hasLoadedCart = true;
    } catch (e) {
      debugPrint('Error clearing cart in Firestore: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get cart items count for specific product
  int getProductQuantity(String productId) {
    final items = _cart.where((item) => item.product.id == productId).toList();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Check if item is in cart
  bool isInCart(String productId, String color, String size) {
    return _cart.any((item) =>
        item.product.id == productId &&
        item.selectedColor == color &&
        item.selectedSize == size);
  }
}
