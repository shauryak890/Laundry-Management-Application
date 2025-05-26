import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

class RiderModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? profileImageUrl;
  final bool isAvailable;
  final int completedOrders;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GeoPoint? lastKnownLocation;

  RiderModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
    required this.isAvailable,
    required this.completedOrders,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.lastKnownLocation,
  });

  factory RiderModel.fromMap(Map<String, dynamic> map) {
    return RiderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      completedOrders: map['completedOrders'] ?? 0,
      rating: (map['rating'] ?? 4.5).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      lastKnownLocation: map['lastKnownLocation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isAvailable': isAvailable,
      'completedOrders': completedOrders,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastKnownLocation': lastKnownLocation,
    };
  }
}
