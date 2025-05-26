import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String iconUrl;
  final Color color;
  final bool isAvailable;
  final int estimatedTimeHours;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.iconUrl,
    required this.color,
    required this.isAvailable,
    required this.estimatedTimeHours,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
      iconUrl: map['iconUrl'] ?? '',
      color: Color(map['color'] ?? 0xFFE3F2FD),
      isAvailable: map['isAvailable'] ?? true,
      estimatedTimeHours: map['estimatedTimeHours'] ?? 24,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'iconUrl': iconUrl,
      'color': color.value,
      'isAvailable': isAvailable,
      'estimatedTimeHours': estimatedTimeHours,
    };
  }
}
