import 'package:flutter/foundation.dart';
import 'dart:convert';

class Location {
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  Location({
    required this.latitude,
    required this.longitude,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] is int ? (json['latitude'] as int).toDouble() : json['latitude'],
      longitude: json['longitude'] is int ? (json['longitude'] as int).toDouble() : json['longitude'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class Rating {
  final String orderId;
  final int rating;
  final String? review;
  final DateTime createdAt;

  Rating({
    required this.orderId,
    required this.rating,
    this.review,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      orderId: json['orderId'],
      rating: json['rating'],
      review: json['review'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class RiderModel {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String status;
  final Location location;
  final List<String> assignedOrders;
  final String? currentOrder;
  final int activeOrderCount;
  final List<Rating> ratings;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  RiderModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.status,
    required this.location,
    required this.assignedOrders,
    this.currentOrder,
    required this.activeOrderCount,
    required this.ratings,
    required this.averageRating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    var riderData = json;
    
    // Extract user info if nested
    if (json['userId'] is Map<String, dynamic>) {
      final userInfo = json['userId'] as Map<String, dynamic>;
      riderData = {
        ...json,
        'name': userInfo['name'],
        'email': userInfo['email'],
        'phoneNumber': userInfo['phoneNumber'],
        'profileImageUrl': userInfo['profileImageUrl'],
        'userId': userInfo['_id'],
      };
    }

    return RiderModel(
      id: riderData['_id'] ?? '',
      userId: riderData['userId'] is String ? riderData['userId'] : riderData['userId']?['_id'] ?? '',
      name: riderData['name'] ?? '',
      email: riderData['email'],
      phoneNumber: riderData['phoneNumber'],
      profileImageUrl: riderData['profileImageUrl'],
      status: riderData['status'] ?? 'offline',
      location: riderData['location'] != null 
          ? Location.fromJson({
              'latitude': riderData['location']['coordinates']?[1] ?? 0.0,
              'longitude': riderData['location']['coordinates']?[0] ?? 0.0,
              'lastUpdated': riderData['location']['lastUpdated'],
            })
          : Location(latitude: 0.0, longitude: 0.0),
      assignedOrders: (riderData['assignedOrders'] as List<dynamic>?)
              ?.map((e) => e is String ? e : e['_id'].toString())
              .toList() ??
          [],
      currentOrder: riderData['currentOrder'] is String 
          ? riderData['currentOrder'] 
          : riderData['currentOrder']?['_id'],
      activeOrderCount: riderData['activeOrderCount'] ?? 0,
      ratings: (riderData['ratings'] as List<dynamic>?)
              ?.map((e) => Rating.fromJson(e))
              .toList() ??
          [],
      averageRating: (riderData['averageRating'] ?? 0.0).toDouble(),
      createdAt: riderData['createdAt'] != null
          ? DateTime.parse(riderData['createdAt'])
          : DateTime.now(),
      updatedAt: riderData['updatedAt'] != null
          ? DateTime.parse(riderData['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'location': location.toJson(),
      'assignedOrders': assignedOrders,
      'currentOrder': currentOrder,
      'activeOrderCount': activeOrderCount,
      'ratings': ratings.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RiderModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? status,
    Location? location,
    List<String>? assignedOrders,
    String? currentOrder,
    int? activeOrderCount,
    List<Rating>? ratings,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RiderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      location: location ?? this.location,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      currentOrder: currentOrder ?? this.currentOrder,
      activeOrderCount: activeOrderCount ?? this.activeOrderCount,
      ratings: ratings ?? this.ratings,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
