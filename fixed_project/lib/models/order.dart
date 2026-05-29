/// Order represents a completed purchase stored in Firestore
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status; // 'pending', 'processing', 'shipped', 'delivered'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.shippingAddress,
  });

  /// Convert Order to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'shippingAddress': shippingAddress,
    };
  }

  /// Create Order from Firestore Map
  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['userId'] as String,
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      shipping: (map['shipping'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String? ?? 'pending',
      createdAt: _readDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _readDateTime(map['updatedAt']),
      shippingAddress: map['shippingAddress'] as String?,
    );
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      final dynamic timestamp = value;
      return timestamp.toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }
}

/// OrderItem represents a single product in an order
class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final String selectedColor;
  final String selectedSize;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
  });

  /// Get subtotal for this order item
  double get subtotal => price * quantity;

  /// Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }

  /// Create OrderItem from Map
  static OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      selectedColor: map['selectedColor'] as String,
      selectedSize: map['selectedSize'] as String,
      quantity: map['quantity'] as int,
    );
  }
}
