import 'package:flutter/foundation.dart';

class AdminLogModel {
  final String id;
  final String adminId;
  final String adminName; // This will be populated on the client side
  final String action;
  final Map<String, dynamic> details;
  final String? ip;
  final String? userAgent;
  final DateTime timestamp;

  AdminLogModel({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.details,
    this.ip,
    this.userAgent,
    required this.timestamp,
  });

  factory AdminLogModel.fromJson(Map<String, dynamic> json) {
    return AdminLogModel(
      id: json['_id'] ?? json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      adminName: json['adminName'] ?? 'Unknown',
      action: json['action'] ?? '',
      details: json['details'] ?? {},
      ip: json['ip'],
      userAgent: json['userAgent'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  String get actionDisplay {
    switch (action) {
      case 'LOGIN':
        return 'Logged in';
      case 'LOGOUT':
        return 'Logged out';
      case 'UPDATE_USER':
        return 'Updated user';
      case 'DELETE_USER':
        return 'Deleted user';
      case 'UPDATE_ORDER_STATUS':
        return 'Updated order status';
      case 'CANCEL_ORDER':
        return 'Cancelled order';
      case 'REFUND_ORDER':
        return 'Refunded order';
      case 'CREATE_SERVICE':
        return 'Created service';
      case 'UPDATE_SERVICE':
        return 'Updated service';
      case 'DELETE_SERVICE':
        return 'Deleted service';
      case 'SEND_NOTIFICATION':
        return 'Sent notification';
      case 'GENERATE_INVOICE':
        return 'Generated invoice';
      case 'ASSIGN_DELIVERY_AGENT':
        return 'Assigned delivery agent';
      default:
        return action;
    }
  }

  String get detailsDisplay {
    try {
      if (details.isEmpty) return '';

      switch (action) {
        case 'UPDATE_ORDER_STATUS':
          return 'Changed order ${details['orderId']} from ${details['previousStatus']} to ${details['newStatus']}';
        case 'SEND_NOTIFICATION':
          return 'To: ${details['userId'] == 'broadcast' ? 'All Users' : 'User ${details['userId']}'}, Title: ${details['title']}';
        case 'CREATE_SERVICE':
          return 'Service name: ${details['serviceName']}';
        case 'UPDATE_SERVICE':
          final changes = details['changes'] ?? {};
          final name = changes['name'] ?? {};
          final price = changes['price'] ?? {};
          return 'Updated ${details['serviceName']}: ${name.isNotEmpty ? 'name ${name['from']} -> ${name['to']}' : ''}${price.isNotEmpty ? ' price ${price['from']} -> ${price['to']}' : ''}';
        default:
          return details.toString();
      }
    } catch (e) {
      debugPrint('Error formatting details: $e');
      return details.toString();
    }
  }
}
