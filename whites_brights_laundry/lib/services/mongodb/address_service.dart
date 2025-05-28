import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whites_brights_laundry/models/address_model.dart';
import 'package:whites_brights_laundry/services/mongodb/api_service.dart';

class AddressService {
  final ApiService _apiService = ApiService();
  
  // Create new address
  Future<AddressModel> createAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    String country = 'India',
    String label = 'home',
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiService.post('/addresses', {
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'label': label,
        'isDefault': isDefault,
      });
      
      return AddressModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Create address error: $e');
      rethrow;
    }
  }
  
  // Get all addresses for current user
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final response = await _apiService.get('/addresses');
      
      final List<AddressModel> addresses = [];
      for (var address in response['data']) {
        addresses.add(AddressModel.fromJson(address));
      }
      
      return addresses;
    } catch (e) {
      debugPrint('Get user addresses error: $e');
      return [];
    }
  }
  
  // Get address by ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final response = await _apiService.get('/addresses/$addressId');
      return AddressModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Get address by ID error: $e');
      return null;
    }
  }
  
  // Update address
  Future<AddressModel?> updateAddress({
    required String addressId,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    String country = 'India',
    String label = 'home',
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiService.put('/addresses/$addressId', {
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'label': label,
        'isDefault': isDefault,
      });
      
      return AddressModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Update address error: $e');
      return null;
    }
  }
  
  // Set address as default
  Future<AddressModel?> setDefaultAddress(String addressId) async {
    try {
      final response = await _apiService.put('/addresses/$addressId', {
        'isDefault': true,
      });
      
      return AddressModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('Set default address error: $e');
      return null;
    }
  }
  
  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _apiService.delete('/addresses/$addressId');
      return true;
    } catch (e) {
      debugPrint('Delete address error: $e');
      return false;
    }
  }
  
  // Stream all addresses for current user
  Stream<List<AddressModel>> streamUserAddresses() {
    final controller = StreamController<List<AddressModel>>.broadcast();
    
    // Initial load and polling every 30 seconds
    _loadAddresses(controller);
    
    Timer.periodic(const Duration(seconds: 30), (_) {
      _loadAddresses(controller);
    });
    
    return controller.stream;
  }
  
  // Helper to load addresses and add to stream
  void _loadAddresses(StreamController<List<AddressModel>> controller) async {
    try {
      final addresses = await getUserAddresses();
      if (!controller.isClosed) {
        controller.add(addresses);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
}
