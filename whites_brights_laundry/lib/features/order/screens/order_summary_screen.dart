import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants.dart';
import '../../../services/providers/order_provider.dart';
import '../../../widgets/buttons.dart';
import '../widgets/summary_item.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final service = orderProvider.selectedService;
    
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
                        value: service['name'],
                        iconData: Icons.local_laundry_service,
                        onEdit: () => context.pop(),
                      ),
                      const Divider(),
                      
                      // Quantity
                      SummaryItem(
                        label: 'Quantity',
                        value: '${orderProvider.itemCount} ${service['unit']}',
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
                      SummaryItem(
                        label: 'Address',
                        value: orderProvider.selectedAddress,
                        iconData: Icons.location_on,
                        onEdit: () => context.push(AppRoutes.profile),
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
                            '${service['name']} x ${orderProvider.itemCount}',
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
                            '₹${orderProvider.totalPrice.toStringAsFixed(0)}',
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
                onPressed: () => _showOrderConfirmation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              AppAssets.successAnimation,
              width: 150,
              height: 150,
              repeat: true,
              // Using a placeholder since we don't have the actual animation file
              // In a real app, we would use a proper animation
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 80,
              ),
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
