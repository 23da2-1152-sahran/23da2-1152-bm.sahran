import 'package:flutter/foundation.dart';
import 'models/cart_item.dart';
import 'models/product.dart';

class AppState extends ChangeNotifier {
  final List<CartItem> _cart = [];
  final Set<String> _savedItems = {};
  int _currentNavIndex = 0;

  List<CartItem> get cart => List.unmodifiable(_cart);
  Set<String> get savedItems => Set.unmodifiable(_savedItems);
  int get currentNavIndex => _currentNavIndex;

  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  double get cartTax => cartSubtotal * 0.1;
  double get cartTotal =>
      cartSubtotal + cartTax + (cartSubtotal > 0 ? 15.0 : 0);

  void addToCart(Product product, String color, String size) {
    final existing = _cart.where(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == color &&
          item.selectedSize == size,
    );
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cart.add(CartItem(
        product: product,
        selectedColor: color,
        selectedSize: size,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity = (item.quantity + delta).clamp(1, 99);
    notifyListeners();
  }

  void toggleSaved(String productId) {
    if (_savedItems.contains(productId)) {
      _savedItems.remove(productId);
    } else {
      _savedItems.add(productId);
    }
    notifyListeners();
  }

  bool isSaved(String productId) => _savedItems.contains(productId);

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }
}
