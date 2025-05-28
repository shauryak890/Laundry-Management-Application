import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/services/mongodb/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();
  final List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add a new address
  Future<void> addAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    String country = 'India',
    String label = 'home',
    bool isDefault = false,
    String addressType = 'home',
  }) async {
    _setLoading(true);
    try {
      final address = await _addressService.createAddress(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: pincode,
        country: country,
        label: label,
        isDefault: isDefault,
      );
      
      _addresses.add(address);
      if (_addresses.length == 1 || isDefault) {
        _selectedAddress = address;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to add address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing address
  Future<void> updateAddress(AddressModel address) async {
    _setLoading(true);
    try {
      await _addressService.updateAddress(
        addressId: address.id,
        addressLine1: address.addressLine1,
        addressLine2: address.addressLine2,
        city: address.city,
        state: address.state,
        pincode: address.pincode,
        country: address.country ?? 'India',
        label: address.label,
        isDefault: address.isDefault,
      );
      
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        if (_selectedAddress?.id == address.id) {
          _selectedAddress = address;
        }
        notifyListeners();
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
      final success = await _addressService.deleteAddress(addressId);
      if (success) {
        _addresses.removeWhere((a) => a.id == addressId);
        if (_selectedAddress?.id == addressId && _addresses.isNotEmpty) {
          _selectedAddress = _addresses.first;
        }
        notifyListeners();
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
    if (loading) {
      _error = null;
    }
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

  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    _setLoading(true);
    try {
      // Find the address to make default
      final address = _addresses.firstWhere((a) => a.id == addressId);
      if (!address.isDefault) {
        // Update the address to be default
        final updatedAddress = address.copyWith(isDefault: true);
        await _addressService.updateAddress(
          addressId: updatedAddress.id,
          addressLine1: updatedAddress.addressLine1,
          addressLine2: updatedAddress.addressLine2,
          city: updatedAddress.city,
          state: updatedAddress.state,
          pincode: updatedAddress.pincode,
          country: updatedAddress.country ?? 'India',
          label: updatedAddress.label,
          isDefault: true,
        );
        
        // Update other addresses to not be default
        for (var otherAddress in _addresses) {
          if (otherAddress.id != addressId && otherAddress.isDefault) {
            final updatedOtherAddress = otherAddress.copyWith(isDefault: false);
            await _addressService.updateAddress(
              addressId: updatedOtherAddress.id,
              addressLine1: updatedOtherAddress.addressLine1,
              addressLine2: updatedOtherAddress.addressLine2,
              city: updatedOtherAddress.city,
              state: updatedOtherAddress.state,
              pincode: updatedOtherAddress.pincode,
              country: updatedOtherAddress.country ?? 'India',
              label: updatedOtherAddress.label,
              isDefault: false,
            );
          }
        }
        
        // Update local state
        final index = _addresses.indexWhere((a) => a.id == addressId);
        if (index != -1) {
          _addresses[index] = updatedAddress;
          _selectedAddress = updatedAddress;
        }
        
        // Update other addresses in local state
        for (int i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id != addressId && _addresses[i].isDefault) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to set default address: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
