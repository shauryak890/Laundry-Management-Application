// No Firebase imports needed for MongoDB

class AddressModel {
  final String id;
  final String userId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final bool isDefault;
  final String label; // home, work, other
  final String? country;
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
    required this.pincode,
    this.landmark,
    required this.isDefault,
    required this.label,
    this.country = 'India',
    String? addressText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.addressText = addressText ?? _generateAddressText(addressLine1, addressLine2, city, state, pincode, landmark),
       this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();
       
  // Helper to generate full address text
  static String _generateAddressText(String addressLine1, String? addressLine2, String city, String state, String pincode, String? landmark) {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2.isNotEmpty) addressLine2,
      if (landmark != null && landmark.isNotEmpty) 'Near $landmark',
      city,
      '$state - $pincode',
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      landmark: json['landmark'],
      isDefault: json['isDefault'] ?? false,
      label: json['label'] ?? 'home',
      country: json['country'],
      addressText: json['addressText'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  
  // For backward compatibility
  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'isDefault': isDefault,
      'label': label,
      'country': country,
      'addressText': addressText,
      // Don't include id, userId, createdAt, updatedAt as they're managed by the server
    };
  }
  
  // For backward compatibility
  Map<String, dynamic> toMap() => toJson();
  
  // CopyWith method for creating a new instance with modified fields
  AddressModel copyWith({
    String? id,
    String? userId,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    bool? isDefault,
    String? label,
    String? country,
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
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
      label: label ?? this.label,
      country: country ?? this.country,
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
    address += ', $city, $state - $pincode';
    if (landmark != null && landmark!.isNotEmpty) {
      address += ' (Near $landmark)';
    }
    return address;
  }
}
