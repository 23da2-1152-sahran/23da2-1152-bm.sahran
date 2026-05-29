class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String image;
  final String description;
  final List<String> size;
  final List<String> colors;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.image,
    required this.description,
    required this.size,
    required this.colors,
    this.createdAt,
  });

  bool get isInStock => stock > 0;

  // Backward-compatible aliases used by the existing cart/detail screens.
  String get imageUrl => image;
  String get subtitle => category;
  String get collection => category;
  String? get badge => null;
  List<String> get sizes => size;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'image': image,
      'description': description,
      'size': size,
      'colors': colors,
      'createdAt': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Product(
      id: documentId ?? map['id'] as String? ?? '',
      // Support both 'name' and 'Name' field keys
      name: _readString(map, ['name', 'Name']) ?? 'Unnamed product',
      // Support both 'category' and 'Categories' (Firestore uses capital C)
      category: _readString(map, ['category', 'Categories', 'Category']) ?? 'All',
      price: _readDouble(
          map['price'] ?? map['Price']),
      stock: _readInt(map['stock'] ?? map['Stock']),
      // Support 'image', 'imageUrl', and the Firestore 'image' URL field
      image: _readImage(map),
      // Support both 'description', 'Description', and the typo 'Discription'
      description: _readString(map, ['description', 'Description', 'Discription']) ?? '',
      size: _readStringList(map['size'] ?? map['sizes'] ?? map['Size'] ?? map['Sizes']),
      colors: _readStringList(map['colors'] ?? map['Colors']),
      createdAt: _readDateTime(map['createdAt']),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? image,
    String? description,
    List<String>? size,
    List<String>? colors,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      description: description ?? this.description,
      size: size ?? this.size,
      colors: colors ?? this.colors,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Read a string value from multiple possible keys
  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readImage(Map<String, dynamic> map) {
    // Check all possible image field names including Firestore URL fields
    final value = map['image'] ?? map['imageUrl'] ?? map['Image'] ?? map['ImageUrl'] ?? '';
    if (value is String) return value;
    return '';
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
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
