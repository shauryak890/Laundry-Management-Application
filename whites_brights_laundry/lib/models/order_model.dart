import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

enum OrderStatus {
  scheduled,
  pickedUp,
  inProcess,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String serviceUnit;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final String timeSlot;
  final String addressId;
  final String addressText;
  final Map<String, DateTime> statusTimestamps;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceUnit,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.pickupDate,
    required this.deliveryDate,
    required this.timeSlot,
    required this.addressId,
    required this.addressText,
    required this.statusTimestamps,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      servicePrice: (json['servicePrice'] is int) 
          ? (json['servicePrice'] as int).toDouble() 
          : json['servicePrice']?.toDouble() ?? 0.0,
      serviceUnit: json['serviceUnit'] ?? '',
      quantity: json['quantity']?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] is int) 
          ? (json['totalPrice'] as int).toDouble() 
          : json['totalPrice']?.toDouble() ?? 0.0,
      status: _parseStatus(json['status']),
      pickupDate: json['pickupDate'] != null 
          ? DateTime.parse(json['pickupDate']) 
          : DateTime.now(),
      deliveryDate: json['deliveryDate'] != null 
          ? DateTime.parse(json['deliveryDate']) 
          : DateTime.now(),
      timeSlot: json['timeSlot'] ?? '',
      addressId: json['addressId'] ?? '',
      addressText: json['addressText'] ?? '',
      statusTimestamps: _parseStatusTimestamps(json['statusTimestamps']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // For backward compatibility
  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel.fromJson(map);

  static Map<String, DateTime> _parseStatusTimestamps(dynamic timestamps) {
    if (timestamps == null) return {};

    final Map<String, DateTime> result = {};
    
    if (timestamps is Map<String, dynamic>) {
      timestamps.forEach((key, value) {
        if (value is String) {
          try {
            result[key] = DateTime.parse(value);
          } catch (e) {
            // Ignore invalid date strings
          }
        }
      });
    }
    
    return result;
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'scheduled':
        return OrderStatus.scheduled;
      case 'pickedUp':
        return OrderStatus.pickedUp;
      case 'inProcess':
        return OrderStatus.inProcess;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.scheduled;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> statusTimestampsMap = {};
    statusTimestamps.forEach((key, value) {
      statusTimestampsMap[key] = value.toIso8601String();
    });

    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'serviceUnit': serviceUnit,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': _statusToString(status),
      'pickupDate': pickupDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'timeSlot': timeSlot,
      'addressId': addressId,
      'addressText': addressText,
      'statusTimestamps': statusTimestampsMap,
      // Don't include id, userId, createdAt, updatedAt as they're managed by the server
    };
  }

  // For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.scheduled:
        return 'scheduled';
      case OrderStatus.pickedUp:
        return 'pickedUp';
      case OrderStatus.inProcess:
        return 'inProcess';
      case OrderStatus.outForDelivery:
        return 'outForDelivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      default:
        return 'scheduled';
    }
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? serviceUnit,
    int? quantity,
    double? totalPrice,
    OrderStatus? status,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? timeSlot,
    String? addressId,
    String? addressText,
    Map<String, DateTime>? statusTimestamps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceUnit: serviceUnit ?? this.serviceUnit,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      timeSlot: timeSlot ?? this.timeSlot,
      addressId: addressId ?? this.addressId,
      addressText: addressText ?? this.addressText,
      statusTimestamps: statusTimestamps ?? this.statusTimestamps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Update order status
  OrderModel updateStatus(OrderStatus newStatus) {
    final updatedStatusTimestamps = Map<String, DateTime>.from(statusTimestamps);
    updatedStatusTimestamps[_statusToString(newStatus)] = DateTime.now();
    
    return copyWith(
      status: newStatus,
      statusTimestamps: updatedStatusTimestamps,
      updatedAt: DateTime.now(),
    );
  }
}

// Constants for order status
class OrderStatusConstants {
  static const String scheduled = 'Scheduled';
  static const String pickedUp = 'Picked Up';
  static const String inProcess = 'In Process';
  static const String outForDelivery = 'Out for Delivery';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';

  static const List<String> allStatuses = [
    scheduled,
    pickedUp,
    inProcess,
    outForDelivery,
    delivered,
    cancelled,
  ];
}
