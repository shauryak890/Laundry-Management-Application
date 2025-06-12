import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderStatus)? onStatusUpdate;
  final bool isCompleted;

  const OrderCard({
    Key? key,
    required this.order,
    this.onStatusUpdate,
    this.isCompleted = false,
  }) : super(key: key);

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.scheduled:
        return Colors.blue;
      case OrderStatus.pickedUp:
        return Colors.amber;
      case OrderStatus.inProcess:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  List<OrderStatus> _getNextPossibleStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.scheduled:
        return [OrderStatus.pickedUp, OrderStatus.cancelled];
      case OrderStatus.pickedUp:
        return [OrderStatus.inProcess, OrderStatus.cancelled];
      case OrderStatus.inProcess:
        return [OrderStatus.outForDelivery, OrderStatus.cancelled];
      case OrderStatus.inProgress:
        return [OrderStatus.outForDelivery, OrderStatus.cancelled];
      case OrderStatus.outForDelivery:
        return [OrderStatus.delivered, OrderStatus.cancelled];
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return [];
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final nextPossibleStatuses = _getNextPossibleStatuses(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                    style: AppTextStyles.heading3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Service info
            Row(
              children: [
                const Icon(
                  Icons.local_laundry_service,
                  color: AppTheme.lightTextColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Service: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${order.serviceName} (${order.quantity} ${order.serviceUnit})',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Customer Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.lightTextColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Address: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    order.addressText,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Pickup and delivery schedule
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.lightTextColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Pickup: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_formatDate(order.pickupDate)} (${order.timeSlot})',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppTheme.lightTextColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Delivery: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatDate(order.deliveryDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),

            // Price
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.payment,
                  color: AppTheme.lightTextColor,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Price: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Status update buttons
            if (!isCompleted && nextPossibleStatuses.isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  const Text(
                    'Update Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: nextPossibleStatuses.map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: ElevatedButton(
                              onPressed: onStatusUpdate != null
                                  ? () => onStatusUpdate!(status)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getStatusColor(status),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                minimumSize: const Size(0, 36),
                              ),
                              child: Text(status == OrderStatus.cancelled
                                  ? 'Cancel'
                                  : 'Mark as ${status.value}'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
