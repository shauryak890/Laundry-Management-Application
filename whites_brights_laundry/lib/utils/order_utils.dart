import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class OrderUtils {
  /// Format OrderStatus enum to display string
  static String formatOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.scheduled:
        return 'Scheduled';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inProcess:
        return 'In Process';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  /// Get color for OrderStatus enum
  static Color getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.scheduled:
        return const Color(0xFFFFA000); // Orange
      case OrderStatus.pickedUp:
        return const Color(0xFF2979FF); // Blue
      case OrderStatus.inProcess:
        return const Color(0xFF9C27B0); // Purple
      case OrderStatus.outForDelivery:
        return const Color(0xFF00BCD4); // Cyan
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Extension method to get status color for OrderModel
  static Color getStatusColor(OrderModel order) {
    return getOrderStatusColor(order.status);
  }
}
