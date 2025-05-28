import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/services/mongodb/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();
  
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _addressesSubscription;
  
  // Getters
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get default address
  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    
    return _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.first,
    );
  }
  
  // Constructor
  AddressProvider() {
    // Start streaming addresses
    _streamAddresses();
  }
  
  // Stream addresses
  void _streamAddresses() {
    _addressesSubscription?.cancel();
    _addressesSubscription = _addressService.streamUserAddresses().listen(
      (addresses) {
        _addresses = addresses;
        
        // If there's a selected address, update it with the latest data
        if (_selectedAddress != null) {
          final updatedAddress = _addresses.firstWhere(
            (address) => address.id == _selectedAddress!.id,
            orElse: () => null as AddressModel,
          );
          
          if (updatedAddress != null) {
            _selectedAddress = updatedAddress;
          }
        }
        
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading addresses: ${error.toString()}');
      }
    );
  }
  
  // Refresh addresses
  Future<void> refreshAddresses() async {
    _setLoading(true);
    
    try {
      _addresses = await _addressService.getUserAddresses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh addresses: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Create new address
  Future<AddressModel?> createAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    String label = 'home',
    String country = 'India',
    bool isDefault = false,
  }) async {
    _setLoading(true);
    
    try {
      final address = await _addressService.createAddress(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: postalCode,
        country: country,
        label: label,
        isDefault: isDefault,
      );
      
      // Add address to list and notify
      await refreshAddresses();
      
      return address;
    } catch (e) {
      _setError('Failed to create address: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update address
  Future<AddressModel?> updateAddress({
    required String addressId,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    String label = 'home',
    String country = 'India',
    bool? isDefault,
  }) async {
    _setLoading(true);
    
    try {
      final updatedAddress = await _addressService.updateAddress(
        addressId: addressId,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: postalCode,
        country: country,
        label: label,
        isDefault: isDefault ?? false,
      );
      
      if (updatedAddress != null) {
        // Update addresses list
        await refreshAddresses();
        
        // Update selected address if needed
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = updatedAddress;
        }
      }
      
      return updatedAddress;
    } catch (e) {
      _setError('Failed to update address: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Set address as default
  Future<bool> setDefaultAddress(String addressId) async {
    _setLoading(true);
    
    try {
      final updatedAddress = await _addressService.setDefaultAddress(addressId);
      
      if (updatedAddress != null) {
        // Update addresses list
        await refreshAddresses();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Failed to set default address: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    _setLoading(true);
    
    try {
      final success = await _addressService.deleteAddress(addressId);
      
      if (success) {
        // Remove address from list
        _addresses.removeWhere((address) => address.id == addressId);
        
        // Clear selected address if needed
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = null;
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to delete address: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Select address
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }
  
  // Clear selected address
  void clearSelectedAddress() {
    _selectedAddress = null;
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _addressesSubscription?.cancel();
    super.dispose();
  }
}
