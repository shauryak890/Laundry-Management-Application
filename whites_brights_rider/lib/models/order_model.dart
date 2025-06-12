import 'package:flutter/foundation.dart';
import 'rider_model.dart';

enum OrderStatus {
  scheduled,
  pickedUp,
  inProcess,
  inProgress, // Added alias for inProcess
  outForDelivery,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.scheduled:
        return 'Scheduled';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inProcess:
        return 'In Process';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.outForDelivery:
        return 'Out For Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  String get value {
    switch (this) {
      case OrderStatus.scheduled:
        return 'scheduled';
      case OrderStatus.pickedUp:
        return 'pickedUp';
      case OrderStatus.inProcess:
        return 'inProcess';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.outForDelivery:
        return 'outForDelivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return OrderStatus.scheduled;
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'inprocess':
        return OrderStatus.inProcess;
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.scheduled;
    }
  }
}

class OrderModel {
  // Order number for display purposes
  String get orderNumber => id.substring(id.length - 6).toUpperCase();
  
  // Total amount is the same as totalPrice for analytics
  double get totalAmount => totalPrice;
  
  // Rating for order (used in analytics)
  double? rating;
  
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
  final String? assignedRider;
  final Location? riderLocation;
  final bool isAssigned;
  final DateTime? assignedAt;
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
    this.assignedRider,
    this.riderLocation,
    required this.isAssigned,
    this.assignedAt,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse rating if available
    double? ratingValue;
    if (json['rating'] != null) {
      ratingValue = double.tryParse(json['rating'].toString()) ?? 0.0;
    }
    
    // Handle statusTimestamps conversion
    final Map<String, DateTime> timestamps = {};
    if (json['statusTimestamps'] != null) {
      (json['statusTimestamps'] as Map<String, dynamic>).forEach((key, value) {
        timestamps[key] = value != null ? DateTime.parse(value) : DateTime.now();
      });
    }

    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      servicePrice: (json['servicePrice'] ?? 0.0).toDouble(),
      serviceUnit: json['serviceUnit'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: OrderStatusExtension.fromString(json['status'] ?? 'scheduled'),
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'])
          : DateTime.now(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : DateTime.now().add(const Duration(days: 2)),
      timeSlot: json['timeSlot'] ?? '',
      addressId: json['addressId'] ?? '',
      addressText: json['addressText'] ?? '',
      statusTimestamps: timestamps,
      assignedRider: json['assignedRider'] is String ? json['assignedRider'] : json['assignedRider']?['_id'],
      rating: ratingValue,
      riderLocation: json['riderLocation'] != null
          ? Location.fromJson({
              'latitude': json['riderLocation']['coordinates']?[1] ?? 0.0,
              'longitude': json['riderLocation']['coordinates']?[0] ?? 0.0,
              'lastUpdated': json['riderLocation']['lastUpdated'],
            })
          : null,
      isAssigned: json['isAssigned'] ?? false,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, String> convertedTimestamps = {};
    statusTimestamps.forEach((key, value) {
      convertedTimestamps[key] = value.toIso8601String();
    });

    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'serviceUnit': serviceUnit,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status.value,
      'pickupDate': pickupDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'timeSlot': timeSlot,
      'addressId': addressId,
      'addressText': addressText,
      'statusTimestamps': convertedTimestamps,
      'assignedRider': assignedRider,
      'riderLocation': riderLocation?.toJson(),
      'isAssigned': isAssigned,
      'assignedAt': assignedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
    };
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
    String? assignedRider,
    Location? riderLocation,
    bool? isAssigned,
    DateTime? assignedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
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
      assignedRider: assignedRider ?? this.assignedRider,
      riderLocation: riderLocation ?? this.riderLocation,
      isAssigned: isAssigned ?? this.isAssigned,
      assignedAt: assignedAt ?? this.assignedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
    );
  }

  OrderModel updateStatus(OrderStatus newStatus) {
    Map<String, DateTime> updatedTimestamps = Map.from(statusTimestamps);
    updatedTimestamps[newStatus.value] = DateTime.now();

    return copyWith(
      status: newStatus,
      statusTimestamps: updatedTimestamps,
      updatedAt: DateTime.now(),
    );
  }

  DateTime? getStatusTimestamp(OrderStatus status) {
    return statusTimestamps[status.value];
  }

  String getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getFormattedTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (status) {
      case OrderStatus.scheduled:
        return 'Scheduled';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inProcess:
        return 'In Process';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.outForDelivery:
        return 'Out For Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
