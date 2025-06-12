import 'package:flutter/material.dart';

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
    Color serviceColor;
    try {
      if (map['color'] != null) {
        if (map['color'] is int) {
          serviceColor = Color(map['color']);
        } else {
          String colorString = map['color'].toString();
          if (colorString.startsWith('#')) {
            serviceColor = Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
          } else if (colorString.startsWith('0x')) {
            serviceColor = Color(int.parse(colorString));
          } else {
            // Default color if parsing fails
            serviceColor = const Color(0xFFE3F2FD);
          }
        }
      } else {
        // Default color if null
        serviceColor = const Color(0xFFE3F2FD);
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
      serviceColor = const Color(0xFFE3F2FD);
    }
    
    return ServiceModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] != null ? double.tryParse(map['price'].toString()) ?? 0.0 : 0.0,
      unit: map['unit'] ?? 'kg',
      iconUrl: map['iconUrl'] ?? '',
      color: serviceColor,
      isAvailable: map['isAvailable'] ?? true,
      estimatedTimeHours: map['estimatedTimeHours'] != null ? 
          int.tryParse(map['estimatedTimeHours'].toString()) ?? 24 : 24,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Don't include id in the request body when creating/updating
      // The backend will handle the ID
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'iconUrl': iconUrl,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'isAvailable': isAvailable,
      'estimatedTimeHours': estimatedTimeHours,
    };
  }
}
