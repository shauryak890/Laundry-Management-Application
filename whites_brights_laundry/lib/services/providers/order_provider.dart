import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';

class OrderProvider extends ChangeNotifier {
  // Selected service properties
  int _selectedServiceId = 0;
  
  // Schedule properties
  DateTime? _pickupDate;
  DateTime? _deliveryDate;
  String _timeSlot = 'Morning';
  
  // Address properties
  String _selectedAddress = '';
  List<String> _savedAddresses = [
    '123 Main St, Apartment 4B, City, State, 12345',
    '456 Park Avenue, Building 7, City, State, 67890',
  ];
  
  // Order properties
  double _totalPrice = 0.0;
  int _itemCount = 1;
  
  // Getters
  int get selectedServiceId => _selectedServiceId;
  DateTime? get pickupDate => _pickupDate;
  DateTime? get deliveryDate => _deliveryDate;
  String get timeSlot => _timeSlot;
  String get selectedAddress => _selectedAddress;
  List<String> get savedAddresses => _savedAddresses;
  double get totalPrice => _totalPrice;
  int get itemCount => _itemCount;
  
  // Get the selected service details
  Map<String, dynamic>? get selectedService {
    if (_selectedServiceId == 0) return null;
    
    final service = ServiceData.services.firstWhere(
      (service) => service['id'] == _selectedServiceId,
      orElse: () => {},
    );
    
    return service.isNotEmpty ? service : null;
  }
  
  // Get formatted pickup date
  String get formattedPickupDate {
    if (_pickupDate == null) return 'Not set';
    return DateFormat('EEEE, MMMM d, yyyy').format(_pickupDate!);
  }
  
  // Get formatted delivery date
  String get formattedDeliveryDate {
    if (_deliveryDate == null) return 'Not set';
    return DateFormat('EEEE, MMMM d, yyyy').format(_deliveryDate!);
  }
  
  // Set selected service
  void setSelectedService(int serviceId) {
    _selectedServiceId = serviceId;
    
    // Update total price based on selected service
    calculateTotalPrice();
    
    notifyListeners();
  }
  
  // Set pickup date
  void setPickupDate(DateTime date) {
    _pickupDate = date;
    
    // If delivery date is not set or is before pickup date,
    // set delivery date to the day after pickup
    if (_deliveryDate == null || _deliveryDate!.isBefore(_pickupDate!)) {
      _deliveryDate = _pickupDate!.add(const Duration(days: 1));
    }
    
    notifyListeners();
  }
  
  // Set delivery date
  void setDeliveryDate(DateTime date) {
    // Ensure delivery date is not before pickup date
    if (_pickupDate != null && date.isBefore(_pickupDate!)) {
      return;
    }
    
    _deliveryDate = date;
    notifyListeners();
  }
  
  // Set time slot
  void setTimeSlot(String slot) {
    _timeSlot = slot;
    notifyListeners();
  }
  
  // Set selected address
  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }
  
  // Add new address
  void addAddress(String address) {
    if (address.isNotEmpty) {
      _savedAddresses.add(address);
      
      // If this is the first address, select it
      if (_selectedAddress.isEmpty) {
        _selectedAddress = address;
      }
      
      notifyListeners();
    }
  }
  
  // Remove address
  void removeAddress(String address) {
    _savedAddresses.remove(address);
    
    // If the removed address was selected, select another one
    if (_selectedAddress == address && _savedAddresses.isNotEmpty) {
      _selectedAddress = _savedAddresses.first;
    } else if (_savedAddresses.isEmpty) {
      _selectedAddress = '';
    }
    
    notifyListeners();
  }
  
  // Set item count
  void setItemCount(int count) {
    if (count > 0) {
      _itemCount = count;
      calculateTotalPrice();
      notifyListeners();
    }
  }
  
  // Calculate total price
  void calculateTotalPrice() {
    if (selectedService == null) {
      _totalPrice = 0.0;
      return;
    }
    
    double servicePrice = selectedService!['price'];
    _totalPrice = servicePrice * _itemCount;
    
    notifyListeners();
  }
  
  // Reset order
  void resetOrder() {
    _selectedServiceId = 0;
    _pickupDate = null;
    _deliveryDate = null;
    _timeSlot = 'Morning';
    _itemCount = 1;
    _totalPrice = 0.0;
    
    notifyListeners();
  }
}
