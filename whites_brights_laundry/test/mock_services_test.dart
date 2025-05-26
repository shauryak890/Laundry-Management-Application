import 'package:flutter_test/flutter_test.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/services/firebase/mock_auth_service.dart';
import 'package:whites_brights_laundry/services/firebase/mock_firestore_service.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_service_factory.dart';

void main() {
  group('Mock Firebase Services Tests', () {
    late MockAuthService authService;
    late MockFirestoreService firestoreService;

    setUp(() {
      authService = MockAuthService();
      firestoreService = MockFirestoreService();
    });

    test('MockAuthService initializes with a test user', () async {
      await authService.initialize();
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.name, 'Test User');
    });

    test('MockFirestoreService can add and retrieve addresses', () async {
      await authService.initialize(); // Ensure we have a logged-in user

      // Add a test address
      final address = await firestoreService.addAddress(
        addressLine1: '123 Test Street',
        city: 'Test City',
        state: 'Test State',
        postalCode: '12345',
        addressType: 'Home',
        isDefault: true,
      );

      expect(address, isNotNull);
      expect(address.addressLine1, '123 Test Street');
      expect(address.isDefault, true);

      // Get addresses and check if our test address is there
      final addressesStream = firestoreService.getUserAddresses();
      final addresses = await addressesStream.first;
      
      expect(addresses, isNotEmpty);
      expect(addresses.first.addressLine1, '123 Test Street');
    });

    test('MockFirestoreService can create and retrieve orders', () async {
      await authService.initialize(); // Ensure we have a logged-in user

      // Add a test address first
      final address = await firestoreService.addAddress(
        addressLine1: '123 Test Street',
        city: 'Test City',
        state: 'Test State',
        postalCode: '12345',
        addressType: 'Home',
        isDefault: true,
      );

      // Create a test order
      final order = await firestoreService.createOrder(
        serviceId: 'service-1',
        serviceName: 'Wash & Fold',
        servicePrice: 199.0,
        serviceUnit: 'kg',
        quantity: 2,
        totalPrice: 398.0,
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        deliveryDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '10:00 AM - 12:00 PM',
        addressId: address.id,
        addressText: address.addressLine1,
      );

      expect(order, isNotNull);
      expect(order.serviceName, 'Wash & Fold');
      expect(order.status, 'pending');

      // Get orders and check if our test order is there
      final ordersStream = firestoreService.getUserOrders();
      final orders = await ordersStream.first;
      
      expect(orders, isNotEmpty);
      expect(orders.first.serviceName, 'Wash & Fold');
    });

    test('FirebaseServiceFactory returns mock services when useMockServices is true', () {
      final factory = FirebaseServiceFactory();
      factory.useMockServices = true;
      
      final authService = factory.getAuthService();
      final firestoreService = factory.getFirestoreService();
      
      expect(authService, isA<MockAuthService>());
      expect(firestoreService, isA<MockFirestoreService>());
    });
  });
}
