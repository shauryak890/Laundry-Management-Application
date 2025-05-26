import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

class OrderModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String serviceUnit;
  final int quantity;
  final double totalPrice;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final String timeSlot;
  final String addressId;
  final String addressText;
  final String status;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, DateTime>? statusTimestamps;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceUnit,
    required this.quantity,
    required this.totalPrice,
    required this.pickupDate,
    required this.deliveryDate,
    required this.timeSlot,
    required this.addressId,
    required this.addressText,
    required this.status,
    this.riderId,
    this.riderName,
    this.riderPhone,
    required this.createdAt,
    required this.updatedAt,
    this.statusTimestamps,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // Parse status timestamps
    Map<String, DateTime> statusTimestamps = {};
    if (map['statusTimestamps'] != null) {
      (map['statusTimestamps'] as Map<String, dynamic>).forEach((key, value) {
        statusTimestamps[key] = (value as Timestamp).toDate();
      });
    }

    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      servicePrice: (map['servicePrice'] ?? 0.0).toDouble(),
      serviceUnit: map['serviceUnit'] ?? '',
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      pickupDate: (map['pickupDate'] as Timestamp).toDate(),
      deliveryDate: (map['deliveryDate'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? 'Morning',
      addressId: map['addressId'] ?? '',
      addressText: map['addressText'] ?? '',
      status: map['status'] ?? 'Scheduled',
      riderId: map['riderId'],
      riderName: map['riderName'],
      riderPhone: map['riderPhone'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      statusTimestamps: statusTimestamps.isNotEmpty ? statusTimestamps : null,
    );
  }

  Map<String, dynamic> toMap() {
    // Convert status timestamps to Firestore timestamps
    Map<String, Timestamp>? firestoreTimestamps;
    if (statusTimestamps != null) {
      firestoreTimestamps = {};
      statusTimestamps!.forEach((key, value) {
        firestoreTimestamps![key] = Timestamp.fromDate(value);
      });
    }

    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'serviceUnit': serviceUnit,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'timeSlot': timeSlot,
      'addressId': addressId,
      'addressText': addressText,
      'status': status,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'statusTimestamps': firestoreTimestamps,
    };
  }

  // Helper method to get the color based on order status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue; // Blue
      case 'Picked Up':
        return Colors.orange; // Orange
      case 'In Process':
        return Colors.purple; // Purple
      case 'Out for Delivery':
        return Colors.teal; // Teal
      case 'Delivered':
        return Colors.green; // Green
      case 'Cancelled':
        return Colors.red; // Red
      default:
        return Colors.blueGrey; // Grey
    }
  }

  // Helper method to update order status with timestamp
  OrderModel updateStatus(String newStatus) {
    final now = DateTime.now();
    final newTimestamps = statusTimestamps ?? {};
    newTimestamps[newStatus] = now;

    return OrderModel(
      id: id,
      userId: userId,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      serviceUnit: serviceUnit,
      quantity: quantity,
      totalPrice: totalPrice,
      pickupDate: pickupDate,
      deliveryDate: deliveryDate,
      timeSlot: timeSlot,
      addressId: addressId,
      addressText: addressText,
      status: newStatus,
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      createdAt: createdAt,
      updatedAt: now,
      statusTimestamps: newTimestamps,
    );
  }

  // Helper method to assign a rider to the order
  OrderModel assignRider(String riderId, String riderName, String riderPhone) {
    return OrderModel(
      id: id,
      userId: userId,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      serviceUnit: serviceUnit,
      quantity: quantity,
      totalPrice: totalPrice,
      pickupDate: pickupDate,
      deliveryDate: deliveryDate,
      timeSlot: timeSlot,
      addressId: addressId,
      addressText: addressText,
      status: status,
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      statusTimestamps: statusTimestamps,
    );
  }
  
  // Helper method to create a copy of this OrderModel with some fields replaced
  OrderModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? serviceUnit,
    int? quantity,
    double? totalPrice,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? timeSlot,
    String? addressId,
    String? addressText,
    String? status,
    String? riderId,
    String? riderName,
    String? riderPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, DateTime>? statusTimestamps,
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
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      timeSlot: timeSlot ?? this.timeSlot,
      addressId: addressId ?? this.addressId,
      addressText: addressText ?? this.addressText,
      status: status ?? this.status,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusTimestamps: statusTimestamps ?? this.statusTimestamps,
    );
  }
}

// Constants for order status
class OrderStatus {
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
