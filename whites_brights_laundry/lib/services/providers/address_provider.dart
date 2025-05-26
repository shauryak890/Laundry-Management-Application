import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service_interface.dart';

class AddressProvider extends ChangeNotifier {
  final FirestoreServiceInterface _firestoreService;
  
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _addressesSubscription;
  
  // Constructor that accepts any FirestoreService implementation
  AddressProvider({required FirestoreServiceInterface firestoreService}) : _firestoreService = firestoreService {
    // Initialize address data when provider is created
    initAddressData();
  }
  
  // Getters
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get default address
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  
  // Initialize address data from Firestore
  void initAddressData() {
    _setLoading(true);
    
    // Cancel any existing subscription
    _addressesSubscription?.cancel();
    
    // Subscribe to user addresses
    _addressesSubscription = _firestoreService.getUserAddresses().listen(
      (addressList) {
        _addresses = addressList;
        
        // Set selected address to default if not already set
        if (_selectedAddress == null && _addresses.isNotEmpty) {
          _selectedAddress = defaultAddress;
        }
        
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading addresses: ${error.toString()}');
      }
    );
  }
  
  // Set selected address
  void setSelectedAddress(String addressId) {
    final address = _addresses.firstWhere(
      (address) => address.id == addressId,
      orElse: () => _addresses.first,
    );
    
    _selectedAddress = address;
    notifyListeners();
  }
  
  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _firestoreService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Update all addresses to not default
      for (var address in _addresses) {
        if (address.id == addressId) {
          // Update this address to be default
          final updatedAddress = address.copyWith(isDefault: true);
          await _firestoreService.updateAddress(updatedAddress);
        } else if (address.isDefault) {
          // Remove default from other addresses
          final updatedAddress = address.copyWith(isDefault: false);
          await _firestoreService.updateAddress(updatedAddress);
        }
      }
      
      // Refresh addresses
      initAddressData();
      return null; // Fix return type
    } catch (e) {
      _setError('Failed to set default address: ${e.toString()}');
    }
  }
  
  // Add a new address
  Future<AddressModel?> addAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    required String addressType,
    bool isDefault = false,
  }) async {
    _setLoading(true);
    
    try {
      // Add to Firestore
      final address = await _firestoreService.addAddress(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        landmark: landmark,
        addressType: addressType,
        isDefault: isDefault,
      );
      
      // Update local state
      _addresses.add(address);
      
      if (address.isDefault) {
        _selectedAddress = address;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add address: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing address
  Future<void> updateAddress(AddressModel address) async {
    _setLoading(true);
    
    try {
      await _firestoreService.updateAddress(address);
      
      // If this is the selected address, update it
      if (_selectedAddress?.id == address.id) {
        _selectedAddress = address;
      }
    } catch (e) {
      _setError('Failed to update address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    _setLoading(true);
    
    try {
      await _firestoreService.deleteAddress(addressId);
      
      // If this is the selected address, reset selected address
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = defaultAddress;
      }
    } catch (e) {
      _setError('Failed to delete address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Cleanup
  @override
  void dispose() {
    _addressesSubscription?.cancel();
    super.dispose();
  }
}
