import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/services/mongodb/order_service.dart';

class OrderProvider extends ChangeNotifier {
  // --- UI State for Schedule/Order Flow ---
  String? _selectedService;
  String? _selectedAddress;
  DateTime? _pickupDate;
  DateTime? _deliveryDate;
  String _timeSlot = 'Morning';
  int _itemCount = 1;
  double _totalPrice = 0.0;
  List<String> _savedAddresses = [];

  // --- UI Getters ---
  String? get selectedService => _selectedService;
  String? get selectedAddress => _selectedAddress ?? '';
  DateTime? get pickupDate => _pickupDate;
  DateTime? get deliveryDate => _deliveryDate;
  String get timeSlot => _timeSlot;
  int get itemCount => _itemCount;
  double get totalPrice => _totalPrice;
  List<String> get savedAddresses => _savedAddresses;
  String get formattedPickupDate => _pickupDate == null ? '' : _pickupDate!.toString().split(' ')[0];
  String get formattedDeliveryDate => _deliveryDate == null ? '' : _deliveryDate!.toString().split(' ')[0];

  // --- UI Setters/Methods ---
  void setSelectedService(dynamic serviceId) {
    // Accept serviceId as int or String
    if (serviceId == null) {
      _selectedService = null;
      _totalPrice = 0.0;
      notifyListeners();
      return;
    }
    _selectedService = serviceId.toString();
    // Price calculation should be handled elsewhere (e.g., when the full service map is available in the schedule/order screen)
    notifyListeners();
  }
  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }
  void setPickupDate(DateTime date) {
    _pickupDate = date;
    notifyListeners();
  }
  void setDeliveryDate(DateTime date) {
    _deliveryDate = date;
    notifyListeners();
  }
  void setTimeSlot(String slot) {
    _timeSlot = slot;
    notifyListeners();
  }
  void setItemCount(int count) {
    _itemCount = count;
    // Recalculate total price if service is selected
    if (_selectedService != null && _selectedService is Map<String, dynamic>) {
      final dynamic priceRaw = (_selectedService as Map<String, dynamic>)['price'];
      double doublePrice = 0.0;
      if (priceRaw is double) {
        doublePrice = priceRaw;
      } else if (priceRaw is int) {
        doublePrice = priceRaw.toDouble();
      } else if (priceRaw is String) {
        doublePrice = double.tryParse(priceRaw) ?? 0.0;
      }
      _totalPrice = doublePrice * _itemCount;
    } else {
      _totalPrice = 0.0;
    }
    notifyListeners();
  }
  void resetOrder() {
    _selectedService = null;
    _selectedAddress = null;
    _pickupDate = null;
    _deliveryDate = null;
    _timeSlot = 'Morning';
    _itemCount = 1;
    _totalPrice = 0.0;
    notifyListeners();
  }

  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _ordersSubscription;
  
  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  OrderProvider() {
    // Start streaming orders
    _streamOrders();
  }
  
  // Stream orders
  void _streamOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService.streamUserOrders().listen(
      (orders) {
        _orders = orders;
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading orders: ${error.toString()}');
      }
    );
  }
  
  // Refresh orders
  Future<void> refreshOrders() async {
    _setLoading(true);
    
    try {
      _orders = await _orderService.getUserOrders();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh orders: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Create new order
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
      final order = await _orderService.createOrder(
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
      
      // Add order to list and notify
      _orders = [order, ..._orders];
      notifyListeners();
      
      return order;
    } catch (e) {
      _setError('Failed to create order: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    // Check if order is already in the list
    final existingOrder = _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => null as OrderModel,
    );
    
    if (existingOrder != null) {
      _selectedOrder = existingOrder;
      notifyListeners();
      return existingOrder;
    }
    
    _setLoading(true);
    
    try {
      final order = await _orderService.getOrderById(orderId);
      
      if (order != null) {
        _selectedOrder = order;
        notifyListeners();
      }
      
      return order;
    } catch (e) {
      _setError('Failed to get order: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    _setLoading(true);
    
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      
      if (updatedOrder != null) {
        // Update order in list
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
        
        // Update selected order if needed
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = updatedOrder;
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Failed to update order status: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    
    try {
      final success = await _orderService.cancelOrder(orderId);
      
      if (success) {
        // Update order in list
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].updateStatus(OrderStatus.cancelled);
        }
        
        // Update selected order if needed
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = _selectedOrder!.updateStatus(OrderStatus.cancelled);
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to cancel order: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Select order
  void selectOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }
  
  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
