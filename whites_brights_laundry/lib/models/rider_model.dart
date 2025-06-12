import 'dart:convert';
import 'package:flutter/foundation.dart';

class Location {
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  Location({
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class RiderModel {
  final String id;
  final String name;
  final String phone; // Changed from phoneNumber to phone
  final String? email;
  final String? profileImageUrl;
  final bool isAvailable;
  final bool isActive; // Added isActive field
  final int completedOrders;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Location? location; // Changed from lastKnownLocation to location
  final String status; // Added status field
  final List<String> assignedOrders; // Added assignedOrders field

  RiderModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
    required this.isAvailable,
    required this.isActive,
    required this.completedOrders,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    required this.status,
    required this.assignedOrders,
  });

  factory RiderModel.fromMap(Map<String, dynamic> map) {
    return RiderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      isActive: map['isActive'] ?? true,
      completedOrders: map['completedOrders'] ?? 0,
      rating: (map['rating'] ?? 4.5).toDouble(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt'])) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] 
              : DateTime.parse(map['updatedAt'])) 
          : DateTime.now(),
      location: map['location'] != null ? Location.fromMap(map['location']) : null,
      status: map['status'] ?? 'available',
      assignedOrders: map['assignedOrders'] != null 
          ? List<String>.from(map['assignedOrders']) 
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'completedOrders': completedOrders,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location?.toMap(),
      'status': status,
      'assignedOrders': assignedOrders,
    };
  }
}
