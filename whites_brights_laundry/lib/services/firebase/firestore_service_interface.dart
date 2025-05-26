import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/models/service_model.dart';

/// Abstract class defining the interface for Firestore services
abstract class FirestoreServiceInterface {
  // User ID
  String? get currentUserId;

  // Services
  Stream<List<ServiceModel>> getServices();
  Future<void> generateSampleServices();

  // Addresses
  Stream<List<AddressModel>> getUserAddresses();
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
  });
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);

  // Orders
  Stream<List<OrderModel>> getUserOrders();
  Stream<OrderModel?> getOrderById(String orderId);
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
  });
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> assignRiderToOrder(String orderId);
}
