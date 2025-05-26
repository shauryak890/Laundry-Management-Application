import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

class AddressModel {
  final String id;
  final String userId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String? landmark;
  final bool isDefault;
  final String addressType; // Home, Work, Other
  final GeoPoint? location;
  final String addressText; // Full address as a single string
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.landmark,
    required this.isDefault,
    required this.addressType,
    this.location,
    String? addressText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.addressText = addressText ?? _generateAddressText(addressLine1, addressLine2, city, state, postalCode, landmark),
       this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();
       
  // Helper to generate full address text
  static String _generateAddressText(String addressLine1, String? addressLine2, String city, String state, String postalCode, String? landmark) {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2.isNotEmpty) addressLine2,
      if (landmark != null && landmark.isNotEmpty) 'Near $landmark',
      city,
      '$state - $postalCode',
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      landmark: map['landmark'],
      isDefault: map['isDefault'] ?? false,
      addressType: map['addressType'] ?? 'Home',
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'landmark': landmark,
      'isDefault': isDefault,
      'addressType': addressType,
      'location': location,
      'addressText': addressText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  // CopyWith method for creating a new instance with modified fields
  AddressModel copyWith({
    String? id,
    String? userId,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? landmark,
    bool? isDefault,
    String? addressType,
    GeoPoint? location,
    String? addressText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
      addressType: addressType ?? this.addressType,
      location: location ?? this.location,
      addressText: addressText ?? this.addressText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress {
    String address = addressLine1;
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      address += ', $addressLine2';
    }
    address += ', $city, $state - $postalCode';
    if (landmark != null && landmark!.isNotEmpty) {
      address += ' (Near $landmark)';
    }
    return address;
  }
}
