import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart' as models;
import '../models/user_profile.dart';

/// FirestoreService handles all Firestore database operations
/// Provides methods for CRUD operations on products, orders, and user data
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _productsCollection = 'products';
  static const String _ordersCollection = 'orders';
  static const String _usersCollection = 'users';
  static const String _cartsCollection = 'carts';
  
  // Timeout constants to prevent ANR (Application Not Responding) crashes
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _profileTimeout = Duration(seconds: 8);

  FirestoreService._internal();

  /// Get singleton instance
  factory FirestoreService() {
    return _instance;
  }

  // ==================== PRODUCTS ====================

  /// Fetch all products from Firestore.
  /// The document ID is used as the product ID, so keep it stable.
  Future<List<Product>> fetchAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .get();
      final products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .toList();
      debugPrint('Fetched ${products.length} products from Firestore');
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      rethrow;
    }
  }

  /// Fetch a single product by ID
  Future<Product?> fetchProductById(String productId) async {
    try {
      final doc =
          await _firestore.collection(_productsCollection).doc(productId).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      rethrow;
    }
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection(_productsCollection).get();
      final results = snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return results;
    } catch (e) {
      debugPrint('Error searching products: $e');
      rethrow;
    }
  }

  /// Stream all products in real-time from Firestore
  /// Automatically notifies listeners when products change
  Stream<List<Product>> streamAllProducts() {
    return _firestore
        .collection(_productsCollection)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .toList();
      debugPrint('Stream: Updated ${products.length} products from Firestore');
      return products;
    }).handleError((error) {
      debugPrint('Error in products stream: $error');
    });
  }

  /// Stream products by category in real-time
  Stream<List<Product>> streamProductsByCategory(String category) {
    return _firestore
        .collection(_productsCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .toList();
    }).handleError((error) {
      debugPrint('Error in category stream: $error');
    });
  }

  // ==================== ORDERS ====================

  /// Create a new order in Firestore
  Future<String> createOrder(models.Order order) async {
    try {
      final docRef = _firestore.collection(_ordersCollection).doc();
      final data = order.toMap();
      data['id'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Fetch user orders
  Future<List<models.Order>> fetchUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .get();
      final orders = snapshot.docs
          .map((doc) => models.Order.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      // Sort by createdAt descending (client-side)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      rethrow;
    }
  }

  /// Fetch a single order by ID
  Future<models.Order?> fetchOrderById(String orderId) async {
    try {
      final doc =
          await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (doc.exists) {
        return models.Order.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching order: $e');
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // ==================== USER PROFILE ====================

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true))
          .timeout(_profileTimeout);
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Fetch user profile with timeout protection
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get()
          .timeout(_profileTimeout);
      
      if (doc.exists) {
        return UserProfile.fromMap({...doc.data()!, 'uid': userId});
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Update user profile fields with timeout
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(data)
          .timeout(_defaultTimeout);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // ==================== CART ====================

  /// Save user cart to Firestore (per-user persistence)
  Future<void> saveCart(
      String userId, List<Map<String, dynamic>> cartItems) async {
    try {
      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .set({
            'items': cartItems,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(_defaultTimeout);
    } catch (e) {
      debugPrint('Error saving cart: $e');
      rethrow;
    }
  }

  /// Fetch user cart from Firestore
  Future<List<Map<String, dynamic>>> fetchCart(String userId) async {
    try {
      final doc =
          await _firestore.collection(_cartsCollection).doc(userId).get();
      if (doc.exists) {
        final items = doc.data()?['items'] as List? ?? [];
        return List<Map<String, dynamic>>.from(items);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      rethrow;
    }
  }

  /// Clear user cart
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection(_cartsCollection).doc(userId).set({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  // ==================== INITIALIZATION ====================

  /// Initialize Firestore with example data (call once during first setup)
  /// This is optional - only for development/testing
  Future<void> initializeWithDemoData() async {
    try {
      final productsRef = _firestore.collection(_productsCollection);

      // Check if products already exist
      final snapshot = await productsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Products already exist, skipping initialization');
        return;
      }

      // Add demo products
      final demoProducts = _getDemoProducts();
      for (final product in demoProducts) {
        await productsRef.doc(product['id']).set(product);
      }

      debugPrint('Demo data initialized successfully');
    } catch (e) {
      debugPrint('Error initializing demo data: $e');
    }
  }

  /// Get demo products for initialization
  List<Map<String, dynamic>> _getDemoProducts() {
    return [
      {
        'id': '1',
        'name': 'Sculptural Wool Overcoat',
        'subtitle': 'Oatmeal Melange',
        'price': 480.00,
        'badge': 'NEW',
        'imageUrl': 'assets/sculptural_wool_overcoat.png',
        'collection': 'WINTER COLLECTION \'24',
        'colors': ['Oatmeal', 'Charcoal', 'Camel'],
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'description':
            'A masterclass in minimal structure. Crafted from premium 100% virgin wool, this coat features defined shoulders and a sleek, hidden placket for a clean editorial silhouette.',
        'category': 'Outerwear',
        'stock': 15,
      },
      {
        'id': '2',
        'name': 'Archival Leather Bag',
        'subtitle': 'Noir Calfskin',
        'price': 1250.00,
        'imageUrl': 'assets/archival_leather_bag.png',
        'collection': 'ACCESSORIES',
        'colors': ['Noir', 'Cognac'],
        'sizes': ['One Size'],
        'description':
            'Structured calfskin leather bag with architectural form and minimal hardware.',
        'category': 'Accessories',
        'stock': 8,
      },
      {
        'id': '3',
        'name': 'Essential Linen Shirt',
        'subtitle': 'Natural White',
        'price': 180.00,
        'badge': 'BESTSELLER',
        'imageUrl': 'assets/essential_linen_shirt.png',
        'collection': 'BASICS',
        'colors': ['White', 'Cream', 'Navy'],
        'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
        'description':
            'Pure linen classic shirt with refined details and perfect versatility.',
        'category': 'Shirts',
        'stock': 50,
      },
    ];
  }
}
