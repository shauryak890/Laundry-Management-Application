import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/models/service_model.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service_interface.dart';
import 'package:whites_brights_laundry/services/firebase/mock_firebase_service.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

/// A mock implementation of Firestore service for development and testing
class MockFirestoreService implements FirestoreServiceInterface {
  // Singleton pattern
  static final MockFirestoreService _instance = MockFirestoreService._internal();
  factory MockFirestoreService() => _instance;
  MockFirestoreService._internal();

  final _uuid = const Uuid();
  final _mockFirebaseService = MockFirebaseService();

  // Mock data storage
  final List<AddressModel> _addresses = [];
  final List<OrderModel> _orders = [];
  final List<Map<String, dynamic>> _services = [
    {
      'id': 'service-1',
      'name': 'Wash & Fold',
      'description': 'Regular washing and folding service for your everyday clothes',
      'price': 199.0,
      'unit': 'kg',
      'color': 0xFFE3F2FD,
      'iconUrl': '',
      'isAvailable': true,
      'estimatedTimeHours': 24,
    },
    {
      'id': 'service-2',
      'name': 'Dry Clean',
      'description': 'Professional dry cleaning for delicate fabrics and formal wear',
      'price': 349.0,
      'unit': 'item',
      'color': 0xFFFFF9C4,
      'iconUrl': '',
      'isAvailable': true,
      'estimatedTimeHours': 48,
    },
    {
      'id': 'service-3',
      'name': 'Ironing',
      'description': 'Expert ironing service to give your clothes a crisp finish',
      'price': 99.0,
      'unit': 'item',
      'color': 0xFFE8F5E9,
      'iconUrl': '',
      'isAvailable': true,
      'estimatedTimeHours': 12,
    },
  ];

  // Getters
  @override
  String? get currentUserId => _mockFirebaseService.currentUserId;

  // Get services
  @override
  Stream<List<ServiceModel>> getServices() {
    return Stream.value(_services.map((data) => ServiceModel.fromMap(data)).toList());
  }

  // Get user addresses
  @override
  Stream<List<AddressModel>> getUserAddresses() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    return Stream.value(_addresses);
  }

  // Add new address
  @override
  Future<AddressModel> addAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    required String addressType,
    bool isDefault = false,
    GeoPoint? location,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // If this is the first address or marked as default, update all other addresses
      if (isDefault) {
        for (var address in _addresses) {
          if (address.isDefault) {
            final index = _addresses.indexOf(address);
            _addresses[index] = address.copyWith(isDefault: false);
          }
        }
      }

      // Check if this is the first address, if so make it default
      if (_addresses.isEmpty) {
        isDefault = true;
      }

      final addressId = _uuid.v4();
      final address = AddressModel(
        id: addressId,
        userId: currentUserId!,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        landmark: landmark,
        isDefault: isDefault,
        addressType: addressType,
        location: location,
        addressText: '$addressLine1, $city, $state - $postalCode',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _addresses.add(address);
      return address;
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  // Update address
  @override
  Future<void> updateAddress(AddressModel address) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // If setting as default, update all other addresses
      if (address.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id != address.id && _addresses[i].isDefault) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
      }

      // Find and update the address
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
      } else {
        throw Exception('Address not found');
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  // Delete address
  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Find and remove the address
      _addresses.removeWhere((address) => address.id == addressId);

      // If we removed the default address and there are other addresses, make the first one default
      if (_addresses.isNotEmpty && !_addresses.any((address) => address.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  // Get user orders
  @override
  Stream<List<OrderModel>> getUserOrders() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    return Stream.value(_orders);
  }

  // Create order
  @override
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
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final orderId = _uuid.v4();
      final now = DateTime.now();
      
      final order = OrderModel(
        id: orderId,
        userId: currentUserId!,
        serviceId: serviceId,
        serviceName: serviceName,
        servicePrice: servicePrice,
        serviceUnit: serviceUnit,
        quantity: quantity,
        totalPrice: totalPrice,
        status: 'pending',
        pickupDate: pickupDate,
        deliveryDate: deliveryDate,
        timeSlot: timeSlot,
        addressId: addressId,
        addressText: addressText,
        createdAt: now,
        updatedAt: now,
      );

      _orders.add(order);
      return order;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Update order status
  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }
  
  // Get order by ID
  @override
  Stream<OrderModel?> getOrderById(String orderId) {
    if (currentUserId == null) {
      return Stream.value(null);
    }
    
    try {
      // Find the order in our mock data
      final order = _orders.firstWhere((order) => order.id == orderId);
      return Stream.value(order);
    } catch (e) {
      debugPrint('Error getting order by ID: $e');
      return Stream.value(null);
    }
  }
  
  // Assign rider to order
  @override
  Future<void> assignRiderToOrder(String orderId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: 'confirmed',
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Order not found');
      }
    } catch (e) {
      debugPrint('Error assigning rider to order: $e');
      rethrow;
    }
  }
  
  // Generate sample services
  @override
  Future<void> generateSampleServices() async {
    // Services are already generated in the constructor
    return;
  }
}
