import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/services/mongodb/api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  
  // Create new order
  Future<OrderModel> createOrder({
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
    String status = 'active', // Default status is 'active' to show in order history
  }) async {
    try {
      final response = await _apiService.post('/orders', {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'servicePrice': servicePrice,
        'serviceUnit': serviceUnit,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'pickupDate': pickupDate.toIso8601String(),
        'deliveryDate': deliveryDate.toIso8601String(),
        'timeSlot': timeSlot,
        'addressId': addressId,
        'addressText': addressText,
        'status': status, // Include status in the order data
      });
      
      return OrderModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Create order error: $e');
      rethrow;
    }
  }
  
  // Get all orders for current user
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final response = await _apiService.get('/orders');
      
      final List<OrderModel> orders = [];
      for (var order in response['data']) {
        orders.add(OrderModel.fromJson(order));
      }
      
      return orders;
    } catch (e) {
      debugPrint('Get user orders error: $e');
      return [];
    }
  }
  
  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      return OrderModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Get order by ID error: $e');
      return null;
    }
  }
  
  // Update order status
  Future<OrderModel?> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await _apiService.put('/orders/$orderId/status', {
        'status': _orderStatusToString(status),
      });
      
      return OrderModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Update order status error: $e');
      return null;
    }
  }
  
  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _apiService.delete('/orders/$orderId');
      return true;
    } catch (e) {
      debugPrint('Cancel order error: $e');
      return false;
    }
  }
  
  // Stream all orders for current user
  Stream<List<OrderModel>> streamUserOrders() {
    final controller = StreamController<List<OrderModel>>.broadcast();
    
    // Initial load and polling every 30 seconds
    _loadOrders(controller);
    
    Timer.periodic(const Duration(seconds: 30), (_) {
      _loadOrders(controller);
    });
    
    return controller.stream;
  }
  
  // Helper to load orders and add to stream
  void _loadOrders(StreamController<List<OrderModel>> controller) async {
    try {
      final orders = await getUserOrders();
      if (!controller.isClosed) {
        controller.add(orders);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
  
  // Convert OrderStatus enum to string
  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.scheduled:
        return 'scheduled';
      case OrderStatus.pickedUp:
        return 'pickedUp';
      case OrderStatus.inProcess:
        return 'inProcess';
      case OrderStatus.outForDelivery:
        return 'outForDelivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      default:
        return 'scheduled';
    }
  }
}
