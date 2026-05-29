import 'package:flutter/foundation.dart';
import '../models/order.dart' as models;
import '../services/firestore_service.dart';

/// OrderProvider manages order state
/// Handles creating orders, fetching order history, and tracking order status
class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<models.Order> _orders = [];
  models.Order? _currentOrder;
  bool _isLoading = false;
  String? _error;
  String? _userId;
  bool _hasLoadedOrders = false;

  // Getters
  List<models.Order> get orders => List.unmodifiable(_orders);
  models.Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize provider with user ID
  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _orders = [];
    _hasLoadedOrders = false;
  }

  /// Clear order state when the user logs out
  void reset() {
    _userId = null;
    _orders = [];
    _currentOrder = null;
    _error = null;
    _hasLoadedOrders = false;
    notifyListeners();
  }

  /// Fetch all orders for current user
  Future<void> fetchOrders({bool forceRefresh = false}) async {
    if (_userId == null) return;
    if (_isLoading) return;
    if (_hasLoadedOrders && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.fetchUserOrders(_userId!);
      _error = null;
      _hasLoadedOrders = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new order
  Future<String?> createOrder(models.Order order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderId = await _firestoreService.createOrder(order);
      final savedOrder = models.Order(
        id: orderId,
        userId: order.userId,
        items: order.items,
        subtotal: order.subtotal,
        tax: order.tax,
        shipping: order.shipping,
        total: order.total,
        status: order.status,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
        shippingAddress: order.shippingAddress,
      );
      _currentOrder = savedOrder;

      // Add to local list
      _orders.insert(0, savedOrder);
      _hasLoadedOrders = true;

      _error = null;
      return orderId;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating order: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch single order details
  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _firestoreService.fetchOrderById(orderId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching order details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateOrderStatus(orderId, newStatus);

      // Update local list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final oldOrder = _orders[index];
        _orders[index] = models.Order(
          id: oldOrder.id,
          userId: oldOrder.userId,
          items: oldOrder.items,
          subtotal: oldOrder.subtotal,
          tax: oldOrder.tax,
          shipping: oldOrder.shipping,
          total: oldOrder.total,
          status: newStatus,
          createdAt: oldOrder.createdAt,
          updatedAt: DateTime.now(),
          shippingAddress: oldOrder.shippingAddress,
        );
      }

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating order status: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get orders by status
  List<models.Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
