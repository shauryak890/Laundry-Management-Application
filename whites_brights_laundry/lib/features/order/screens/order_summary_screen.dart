import 'package:flutter/material.dart';
import '../../../core/map_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants.dart';
import '../../../models/service_model.dart';
import '../../../services/providers/order_provider_mongodb.dart';
import '../../../services/providers/address_provider_mongodb.dart';
import '../../../services/providers/service_provider.dart';
import '../../../services/mongodb/order_service.dart';
import '../../../models/address_model.dart';
import '../../../widgets/buttons.dart';
import '../widgets/summary_item.dart';
import '../../../widgets/bottom_nav_bar.dart';

Color? parseColor(dynamic colorValue) {
  if (colorValue is int) return Color(colorValue);
  if (colorValue is String) {
    String hex = colorValue.replaceAll('#', '').replaceAll('0x', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.tryParse('0x$hex') ?? 0xFF000000);
  }
  return null;
}

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final serviceId = orderProvider.selectedService;
    
    // Get the full service details from ServiceProvider using the ID
    final service = serviceProvider.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId ?? '1',
        name: 'Wash & Fold',
        description: '',
        price: 199.0,
        unit: 'kg',
        iconUrl: '',
        color: Colors.blue,
        isAvailable: true,
        estimatedTimeHours: 24,
      ),
    );
    // Extract service fields safely
    String serviceName = service.name;
    String serviceUnit = service.unit;
    double servicePrice = service.price;
    Color serviceColor = service.color;
    
    // Ensure we have a default price if none is available
    if (servicePrice <= 0) {
      servicePrice = 199; // Updated default price
    }
    
    // Calculate the total price based on quantity
    final totalPrice = servicePrice * orderProvider.itemCount;

    if (service == null) {
      // Service not found, go back to home
      Future.microtask(() => context.go(AppRoutes.home));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orderSummary),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1, // Orders tab
        onItemSelected: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0: // Home
              context.go(AppRoutes.home);
              break;
            case 1: // Orders - already here
              break;
            case 2: // Schedule
              // Navigate to schedule with a default service
              context.push(AppRoutes.schedule, extra: 1);
              break;
            case 3: // Profile
              context.push(AppRoutes.profile);
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Details Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Service Details
                      SummaryItem(
                        label: 'Service',
                        value: serviceName,
                        iconData: Icons.local_laundry_service,
                        onEdit: () => context.pop(),
                      ),
                      const Divider(),
                      
                      // Quantity
                      SummaryItem(
                        label: 'Quantity',
                        value: '${orderProvider.itemCount} $serviceUnit',
                        iconData: Icons.shopping_bag,
                        onEdit: () => context.pop(),
                      ),
                      const Divider(),
                      
                      // Pickup Date
                      SummaryItem(
                        label: 'Pickup Date',
                        value: orderProvider.formattedPickupDate,
                        iconData: Icons.calendar_today,
                        onEdit: () => context.pop(),
                      ),
                      const Divider(),
                      
                      // Delivery Date
                      SummaryItem(
                        label: 'Delivery Date',
                        value: orderProvider.formattedDeliveryDate,
                        iconData: Icons.calendar_today,
                        onEdit: () => context.pop(),
                      ),
                      const Divider(),
                      
                      // Time Slot
                      SummaryItem(
                        label: 'Time Slot',
                        value: orderProvider.timeSlot,
                        iconData: Icons.access_time,
                        onEdit: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Address Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final addressProvider = Provider.of<AddressProvider>(context);
                          final orderProvider = Provider.of<OrderProvider>(context);
                          final selectedAddress = addressProvider.addresses.firstWhere(
                            (a) => a.id == orderProvider.selectedAddress,
                            orElse: () => AddressModel(id: '', userId: '', addressLine1: '', city: '', state: '', pincode: '', isDefault: false, label: 'home'),
                          );
                          if (selectedAddress.id.isEmpty) {
                            return const Text('No address selected', style: TextStyle(color: Colors.red));
                          }
                          return Text(
                            '${selectedAddress.addressLine1}, ${selectedAddress.city}, ${selectedAddress.state} - ${selectedAddress.pincode}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Price Summary Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${serviceName} x ${orderProvider.itemCount}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '₹${orderProvider.totalPrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${(servicePrice * orderProvider.itemCount).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Place Order Button
              PrimaryButton(
                text: AppStrings.placeOrder,
                onPressed: () {
                // Save order to MongoDB before showing confirmation
                _saveOrderToMongoDB(context);
                _showOrderConfirmation(context);
              },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Save order to MongoDB
  Future<void> _saveOrderToMongoDB(BuildContext context) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      
      // Get service details
      final serviceId = orderProvider.selectedService;
      final service = serviceProvider.services.firstWhere(
        (s) => s.id == serviceId,
        orElse: () => ServiceModel(
          id: serviceId ?? '1',
          name: 'Wash & Fold',
          description: '',
          price: 199.0,
          unit: 'kg',
          iconUrl: '',
          color: Colors.blue,
          isAvailable: true,
          estimatedTimeHours: 24,
        ),
      );
      
      // Get address details
      final addressId = orderProvider.selectedAddress ?? '';
      final address = addressProvider.addresses.firstWhere(
        (a) => a.id == addressId,
        orElse: () => AddressModel(id: '', userId: '', addressLine1: 'Default Address', city: '', state: '', pincode: '', isDefault: false, label: ''),
      );
      final addressText = '${address.addressLine1}, ${address.city}, ${address.state} - ${address.pincode}';
      
      // Parse dates
      final pickupDate = orderProvider.pickupDate ?? DateTime.now().add(const Duration(days: 1));
      final deliveryDate = orderProvider.deliveryDate ?? DateTime.now().add(const Duration(days: 2));
      
      // Calculate total price
      final totalPrice = service.price * orderProvider.itemCount;

      // Call the order service to save the order with named parameters
      await OrderService().createOrder(
        serviceId: serviceId.toString(),
        serviceName: service.name,
        servicePrice: service.price,
        serviceUnit: service.unit,
        quantity: orderProvider.itemCount,
        totalPrice: totalPrice,
        pickupDate: pickupDate,
        deliveryDate: deliveryDate,
        timeSlot: orderProvider.timeSlot,
        addressId: addressId,
        addressText: addressText,
        status: 'scheduled', // Use 'scheduled' which is a valid OrderStatus value
      );
      
      debugPrint('Order saved to MongoDB successfully');
    } catch (e) {
      debugPrint('Error saving order to MongoDB: $e');
    }
  }
  
  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon instead of animation to avoid asset errors
            const Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your order has been placed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset order and go back to home
              Provider.of<OrderProvider>(context, listen: false).resetOrder();
              context.go(AppRoutes.home);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
