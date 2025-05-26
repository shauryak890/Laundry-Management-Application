import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/models/service_model.dart';
import 'package:whites_brights_laundry/models/rider_model.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_service.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service_interface.dart';

class FirestoreService implements FirestoreServiceInterface {
  final dynamic _firestore = FirebaseService.instance.firestore;
  final String? _userId = FirebaseService.instance.currentUserId;
  final _uuid = const Uuid();

  // References to collections
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _ordersRef => _firestore.collection('orders');
  CollectionReference get _servicesRef => _firestore.collection('services');
  CollectionReference get _addressesRef => _firestore.collection('addresses');
  CollectionReference get _ridersRef => _firestore.collection('riders');
  
  // Getter for current user ID
  @override
  String? get currentUserId => _userId;

  // Get services
  @override
  Stream<List<ServiceModel>> getServices() {
    return _servicesRef
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get user addresses
  @override
  Stream<List<AddressModel>> getUserAddresses() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _addressesRef
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
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
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // If this is the first address or marked as default, update all other addresses
      if (isDefault) {
        final existingAddresses = await _addressesRef
            .where('userId', isEqualTo: _userId)
            .where('isDefault', isEqualTo: true)
            .get();

        final batch = _firestore.batch();
        for (var doc in existingAddresses.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }
        await batch.commit();
      }

      // Check if this is the first address, if so make it default
      if ((await _addressesRef.where('userId', isEqualTo: _userId).get()).docs.isEmpty) {
        isDefault = true;
      }

      final addressId = _uuid.v4();
      final address = AddressModel(
        id: addressId,
        userId: _userId!,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        landmark: landmark,
        isDefault: isDefault,
        addressType: addressType,
        location: location,
      );

      await _addressesRef.doc(addressId).set(address.toMap());
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
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // If setting as default, update all other addresses
      if (address.isDefault) {
        final existingAddresses = await _addressesRef
            .where('userId', isEqualTo: _userId)
            .where('isDefault', isEqualTo: true)
            .where('id', isNotEqualTo: address.id)
            .get();

        final batch = _firestore.batch();
        for (var doc in existingAddresses.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }
        await batch.commit();
      }

      await _addressesRef.doc(address.id).update(address.toMap());
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  // Delete address
  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final address = await _addressesRef.doc(addressId).get();
      
      if (!address.exists) {
        throw Exception('Address not found');
      }

      final addressData = address.data() as Map<String, dynamic>;
      
      // If deleting a default address, set another one as default
      if (addressData['isDefault'] == true) {
        final otherAddresses = await _addressesRef
            .where('userId', isEqualTo: _userId)
            .where('id', isNotEqualTo: addressId)
            .limit(1)
            .get();

        if (otherAddresses.docs.isNotEmpty) {
          await _addressesRef.doc(otherAddresses.docs.first.id).update({
            'isDefault': true
          });
        }
      }

      await _addressesRef.doc(addressId).delete();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
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
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final orderId = _uuid.v4();
      final now = DateTime.now();
      
      // Create status timestamps map
      final statusTimestamps = {
        OrderStatus.scheduled: now,
      };

      final order = OrderModel(
        id: orderId,
        userId: _userId!,
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
        status: OrderStatus.scheduled,
        createdAt: now,
        updatedAt: now,
        statusTimestamps: statusTimestamps,
      );

      await _ordersRef.doc(orderId).set(order.toMap());
      return order;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Get user orders
  @override
  Stream<List<OrderModel>> getUserOrders() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _ordersRef
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get order by ID
  @override
  Stream<OrderModel?> getOrderById(String orderId) {
    return _ordersRef
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return OrderModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  // Update order status
  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final orderDoc = await _ordersRef.doc(orderId).get();
      
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order = OrderModel.fromMap(orderDoc.data() as Map<String, dynamic>);
      final updatedOrder = order.updateStatus(status);

      await _ordersRef.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'statusTimestamps': updatedOrder.statusTimestamps != null
            ? updatedOrder.statusTimestamps!.map((key, value) => 
                MapEntry(key, Timestamp.fromDate(value)))
            : null,
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Assign rider to order
  @override
  Future<void> assignRiderToOrder(String orderId) async {
    try {
      // Get a random rider from the riders collection
      final ridersSnapshot = await _ridersRef
          .where('isAvailable', isEqualTo: true)
          .limit(1)
          .get();

      if (ridersSnapshot.docs.isEmpty) {
        debugPrint('No available riders found');
        return;
      }

      final riderDoc = ridersSnapshot.docs.first;
      final rider = RiderModel.fromMap(riderDoc.data() as Map<String, dynamic>);

      await _ordersRef.doc(orderId).update({
        'riderId': rider.id,
        'riderName': rider.name,
        'riderPhone': rider.phoneNumber,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error assigning rider to order: $e');
      rethrow;
    }
  }

  // Generate sample riders (for development purposes)
  Future<void> generateSampleRiders() async {
    try {
      final ridersSample = [
        {
          'name': 'Rahul Sharma',
          'phoneNumber': '+919876543210',
          'isAvailable': true,
          'completedOrders': 125,
          'rating': 4.8,
        },
        {
          'name': 'Amit Kumar',
          'phoneNumber': '+919876543211',
          'isAvailable': true,
          'completedOrders': 89,
          'rating': 4.6,
        },
        {
          'name': 'Priya Singh',
          'phoneNumber': '+919876543212',
          'isAvailable': true,
          'completedOrders': 157,
          'rating': 4.9,
        },
      ];

      final batch = _firestore.batch();
      final now = DateTime.now();

      for (var riderData in ridersSample) {
        final riderId = _uuid.v4();
        final rider = RiderModel(
          id: riderId,
          name: riderData['name'] as String,
          phoneNumber: riderData['phoneNumber'] as String,
          isAvailable: riderData['isAvailable'] as bool,
          completedOrders: riderData['completedOrders'] as int,
          rating: riderData['rating'] as double,
          createdAt: now,
          updatedAt: now,
        );

        batch.set(_ridersRef.doc(riderId), rider.toMap());
      }

      await batch.commit();
      debugPrint('Sample riders generated successfully');
    } catch (e) {
      debugPrint('Error generating sample riders: $e');
    }
  }

  // Generate sample services (for development purposes)
  @override
  Future<void> generateSampleServices() async {
    try {
      final servicesSample = [
        {
          'name': 'Wash & Fold',
          'description': 'Regular washing and folding service for your everyday clothes',
          'price': 199.0,
          'unit': 'kg',
          'color': 0xFFE3F2FD,
          'estimatedTimeHours': 24,
        },
        {
          'name': 'Dry Clean',
          'description': 'Professional dry cleaning for delicate fabrics and formal wear',
          'price': 349.0,
          'unit': 'item',
          'color': 0xFFFFF9C4,
          'estimatedTimeHours': 48,
        },
        {
          'name': 'Ironing',
          'description': 'Expert ironing service to give your clothes a crisp finish',
          'price': 99.0,
          'unit': 'item',
          'color': 0xFFE8F5E9,
          'estimatedTimeHours': 12,
        },
        {
          'name': 'Premium Wash',
          'description': 'Specialized washing for premium and delicate clothing items',
          'price': 499.0,
          'unit': 'kg',
          'color': 0xFFFFECB3,
          'estimatedTimeHours': 36,
        },
      ];

      final batch = _firestore.batch();

      for (var serviceData in servicesSample) {
        final serviceId = _uuid.v4();
        final service = ServiceModel(
          id: serviceId,
          name: serviceData['name'] as String,
          description: serviceData['description'] as String,
          price: serviceData['price'] as double,
          unit: serviceData['unit'] as String,
          iconUrl: '',
          color: Color(serviceData['color'] as int),
          isAvailable: true,
          estimatedTimeHours: serviceData['estimatedTimeHours'] as int,
        );

        batch.set(_servicesRef.doc(serviceId), service.toMap());
      }

      await batch.commit();
      debugPrint('Sample services generated successfully');
    } catch (e) {
      debugPrint('Error generating sample services: $e');
    }
  }
}
