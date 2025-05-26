import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service_interface.dart';
import 'package:whites_brights_laundry/services/firebase/notification_service.dart';

class OrderProviderFirebase extends ChangeNotifier {
  final FirestoreServiceInterface _firestoreService;
  final NotificationService _notificationService;
  
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _selectedOrderSubscription;
  
  // Constructor that accepts any FirestoreService implementation
  OrderProviderFirebase({
    required FirestoreServiceInterface firestoreService,
    NotificationService? notificationService,
  }) : 
    _firestoreService = firestoreService,
    _notificationService = notificationService ?? NotificationService() {
    // Initialize order data when provider is created
    initOrderData();
  }
  
  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get filtered orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }
  
  // Get active orders (not delivered or cancelled)
  List<OrderModel> get activeOrders {
    return _orders.where((order) => 
      order.status != OrderStatus.delivered && 
      order.status != OrderStatus.cancelled
    ).toList();
  }
  
  // Get completed orders (delivered or cancelled)
  List<OrderModel> get completedOrders {
    return _orders.where((order) => 
      order.status == OrderStatus.delivered || 
      order.status == OrderStatus.cancelled
    ).toList();
  }
  
  // Initialize order data from Firestore
  void initOrderData() {
    _setLoading(true);
    
    // Cancel any existing subscription
    _ordersSubscription?.cancel();
    
    // Subscribe to user orders
    _ordersSubscription = _firestoreService.getUserOrders().listen(
      (ordersList) {
        _orders = ordersList;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading orders: ${error.toString()}');
      }
    );
  }
  
  // Get order by ID and listen for updates
  void getOrderById(String orderId) {
    _setLoading(true);
    
    // Cancel any existing subscription
    _selectedOrderSubscription?.cancel();
    
    // Subscribe to order updates
    _selectedOrderSubscription = _firestoreService.getOrderById(orderId).listen(
      (order) {
        _selectedOrder = order;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading order details: ${error.toString()}');
      }
    );
  }
  
  // Create a new order
  Future<OrderModel?> createOrder({
    required String serviceId,
    required String serviceName,
    required double servicePrice,
    required String serviceUnit,
    required int quantity,
    required double totalPrice,
    required DateTime pickupDate,
    required DateTime deliveryDate,
    required String timeSlot,
    required String addressId,
    required String addressText,
  }) async {
    _setLoading(true);
    
    try {
      final order = await _firestoreService.createOrder(
        serviceId: serviceId,
        serviceName: serviceName,
        servicePrice: servicePrice,
        serviceUnit: serviceUnit,
        quantity: quantity,
        totalPrice: totalPrice,
        pickupDate: pickupDate,
        deliveryDate: deliveryDate,
        timeSlot: timeSlot,
        addressId: addressId,
        addressText: addressText,
      );
      
      // Simulate rider assignment after 5 seconds
      _simulateRiderAssignment(order.id);
      
      return order;
    } catch (e) {
      _setError('Failed to create order: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      
      // Show local notification for status update
      if (_selectedOrder != null) {
        final updatedOrder = _selectedOrder!.updateStatus(status);
        _notificationService.showOrderStatusNotification(updatedOrder);
      }
    } catch (e) {
      _setError('Failed to update order status: ${e.toString()}');
    }
  }
  
  // Simulate rider assignment (for development purposes)
  Future<void> _simulateRiderAssignment(String orderId) async {
    // Wait 5 seconds before assigning rider
    await Future.delayed(const Duration(seconds: 5));
    
    try {
      await _firestoreService.assignRiderToOrder(orderId);
    } catch (e) {
      debugPrint('Error in rider assignment simulation: $e');
    }
  }
  
  // Simulate order progress (for development purposes)
  Future<void> simulateOrderProgress(String orderId) async {
    // Simulate order progress through different statuses
    final statusTimeline = [
      OrderStatus.pickedUp,
      OrderStatus.inProcess,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    
    for (var status in statusTimeline) {
      // Delay between status updates
      await Future.delayed(const Duration(seconds: 15));
      
      try {
        await updateOrderStatus(orderId, status);
      } catch (e) {
        debugPrint('Error in order progress simulation: $e');
        break;
      }
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Cleanup
  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _selectedOrderSubscription?.cancel();
    super.dispose();
  }
}
