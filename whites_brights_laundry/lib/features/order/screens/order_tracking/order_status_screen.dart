import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants.dart';
import '../../../../models/order_model.dart';
import '../../../../services/providers/order_provider_mongodb.dart';
import '../../../../widgets/buttons.dart';
import 'status_timeline.dart';
import 'rider_info_card.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;

  const OrderStatusScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.grey;
      case 'pickedUp':
        return Colors.orange;
      case 'inProcess':
        return Colors.blue;
      case 'outForDelivery':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch order details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<OrderProvider>(context, listen: false)
            .getOrderById(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final order = orderProvider.selectedOrder;
        final isLoading = orderProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              order != null 
                ? 'Order #${order.id.substring(0, 8)}'
                : 'Order Details',
            ),
            actions: [
              if (order != null && order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () => _showCancelDialog(context, order),
                ),
            ],
          ),
          body: isLoading
              ? _buildLoadingState()
              : order == null
                  ? _buildErrorState()
                  : _buildOrderStatusContent(context, order),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Order not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The order you are looking for could not be found.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            text: 'Go Back',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusContent(BuildContext context, OrderModel order) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          _buildStatusCard(order),
          const SizedBox(height: 24),
          
          // Order Status Timeline
          StatusTimeline(order: order),
          const SizedBox(height: 24),
          
          // Rider Information (if assigned)
          if (null != null && null != null)
            RiderInfoCard(
              name: null!,
              phone: 'Not available' ?? 'Not available',
            ),
          if (null != null)
            const SizedBox(height: 24),
          
          // Order Details
          Card(
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
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Service',
                    order.serviceName,
                    Icons.local_laundry_service,
                  ),
                  _buildDetailRow(
                    context,
                    'Quantity',
                    '${order.quantity} ${order.serviceUnit}',
                    Icons.shopping_bag,
                  ),
                  _buildDetailRow(
                    context,
                    'Price',
                    '₹${order.totalPrice.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                  ),
                  _buildDetailRow(
                    context,
                    'Pickup Date',
                    dateFormat.format(order.pickupDate),
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    'Pickup Time',
                    order.timeSlot,
                    Icons.access_time,
                  ),
                  _buildDetailRow(
                    context,
                    'Delivery Date',
                    dateFormat.format(order.deliveryDate),
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    'Address',
                    order.addressText,
                    Icons.location_on,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Order Timestamps
          if (order.statusTimestamps != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Timeline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...order.statusTimestamps!.entries.map((entry) {
                      return _buildTimelineRow(
                        context,
                        entry.key,
                        '${dateFormat.format(entry.value)} at ${timeFormat.format(entry.value)}',
                        isLast: entry.key == order.status.name,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          
          // If order is completed, show support button
          if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled)
            Center(
              child: SecondaryButton(
                text: 'Need Help?',
                onPressed: () => _showSupportDialog(context),
                icon: Icons.support_agent,
              ),
            ),
          
          // For simulation purposes - allow force update
          if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
            Center(
              child: TextButton(
                onPressed: () {
                  Provider.of<OrderProvider>(context, listen: false);
                      // simulateOrderProgress removed for MongoDB migration;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order progress simulation started'),
                    ),
                  );
                },
                child: const Text('Simulate Order Progress'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(order.status.name),
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    String status,
    String timestamp, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                size: 18,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestamp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case OrderStatus.scheduled:
        return Icons.schedule;
      case OrderStatus.pickedUp:
        return Icons.inventory;
      case OrderStatus.inProcess:
        return Icons.local_laundry_service;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<OrderProvider>(context, listen: false)
                  .updateOrderStatus(order.id, OrderStatus.cancelled);
            },
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'If you need assistance with your order, please contact our customer support:',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text('+91 98765 43210'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text('support@whitesandbrights.com'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
