import 'product.dart';

/// CartItem represents a product added to cart with selected options
class CartItem {
  final Product product;
  final String selectedColor;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.quantity = 1,
  });

  /// Get subtotal for this cart item (price × quantity)
  double get subtotal => product.price * quantity;

  /// Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }

  /// Create CartItem from Firestore Map
  static CartItem fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      selectedColor: map['selectedColor'] as String,
      selectedSize: map['selectedSize'] as String,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}
