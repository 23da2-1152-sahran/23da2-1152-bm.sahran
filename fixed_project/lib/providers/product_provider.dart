import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/firestore_service.dart';

/// ProductProvider manages product state
/// Handles real-time products from Firestore and category filtering
class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Product>>? _productStreamSubscription;

  // Getters
  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get filteredProducts => List.unmodifiable(_filteredProducts);
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories {
    final cats = <String>{'All'};
    for (final product in _allProducts) {
      if (product.category.trim().isNotEmpty) {
        cats.add(product.category);
      }
    }
    return cats.toList();
  }

  /// Constructor: automatically starts real-time listener on creation
  ProductProvider() {
    initializeProductListener();
  }

  /// Initialize real-time product listener
  /// Automatically updates UI when Firestore data changes
  void initializeProductListener() {
    debugPrint('Initializing real-time product listener...');
    _isLoading = true;
    // Use scheduleMicrotask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

    try {
      _productStreamSubscription?.cancel();
      _productStreamSubscription = _firestoreService.streamAllProducts().listen(
        (products) {
          debugPrint('Products stream updated: ${products.length} products');
          _allProducts = products;
          _filterProducts();
          _error = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          debugPrint('Error in product stream: $error');
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error initializing product listener: $e');
      notifyListeners();
    }
  }

  /// Fetch all products from Firestore (calls initializeProductListener)
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // Stream is already running from constructor; just re-init if needed
    if (_productStreamSubscription == null) {
      initializeProductListener();
    }
  }

  /// Filter products by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterProducts();
    notifyListeners();
  }

  /// Apply category filter
  void _filterProducts() {
    if (_selectedCategory == 'All') {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _filteredProducts = await _firestoreService.searchProducts(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset to all products
  void resetFilter() {
    _selectedCategory = 'All';
    _filterProducts();
    notifyListeners();
  }

  /// Cleanup: dispose the stream subscription
  @override
  void dispose() {
    _productStreamSubscription?.cancel();
    super.dispose();
  }
}
