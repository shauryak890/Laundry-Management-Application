import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants.dart';
import '../../../../models/order_model.dart';

class StatusTimeline extends StatelessWidget {
  final OrderModel order;

  const StatusTimeline({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define all possible statuses in order
    final allStatuses = OrderStatus.allStatuses;
    
    // Determine the current status index
    final currentStatusIndex = allStatuses.indexOf(order.status);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Build timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allStatuses.length,
              itemBuilder: (context, index) {
                // Skip cancelled status if order is not cancelled
                if (allStatuses[index] == OrderStatus.cancelled && 
                    order.status != OrderStatus.cancelled) {
                  return const SizedBox.shrink();
                }
                
                // Determine if this status is completed, active, or pending
                bool isCompleted = index <= currentStatusIndex && 
                                   order.status != OrderStatus.cancelled;
                bool isActive = index == currentStatusIndex;
                bool isLast = index == allStatuses.length - 1 || 
                             (order.status == OrderStatus.cancelled && 
                              allStatuses[index] == OrderStatus.cancelled);
                
                // For cancelled orders, only show scheduled and cancelled
                if (order.status == OrderStatus.cancelled && 
                    allStatuses[index] != OrderStatus.scheduled && 
                    allStatuses[index] != OrderStatus.cancelled) {
                  return const SizedBox.shrink();
                }
                
                return _buildTimelineItem(
                  context,
                  status: allStatuses[index],
                  isCompleted: isCompleted,
                  isActive: isActive,
                  isLast: isLast,
                  animationDelay: (index * 300).ms,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String status,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required Duration animationDelay,
  }) {
    // Define colors based on status
    final Color color = isActive || isCompleted
        ? OrderModel.getStatusColor(status)
        : Colors.grey.shade300;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: color.withOpacity(0.5), width: 4)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ).animate(delay: animationDelay).scale(duration: 400.ms),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? color : Colors.grey.shade300,
              ).animate(delay: animationDelay + 200.ms).fadeIn(duration: 300.ms).shimmer(),
          ],
        ),
        const SizedBox(width: 16),
        
        // Status content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive || isCompleted
                      ? OrderModel.getStatusColor(status)
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusDescription(status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: isLast ? 8 : 32),
            ],
          ),
        ),
      ],
    ).animate(delay: animationDelay).fadeIn(duration: 500.ms).slideX(begin: 0.2, end: 0);
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case OrderStatus.scheduled:
        return 'Your order has been scheduled for pickup';
      case OrderStatus.pickedUp:
        return 'Your laundry has been picked up';
      case OrderStatus.inProcess:
        return 'Your laundry is being cleaned and processed';
      case OrderStatus.outForDelivery:
        return 'Your clean laundry is on the way to you';
      case OrderStatus.delivered:
        return 'Your laundry has been delivered successfully';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }
}
