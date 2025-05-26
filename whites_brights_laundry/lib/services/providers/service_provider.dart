import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/service_model.dart';
import 'package:whites_brights_laundry/services/firebase/firestore_service_interface.dart';

class ServiceProvider extends ChangeNotifier {
  final FirestoreServiceInterface _firestoreService;
  
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _servicesSubscription;
  
  // Constructor that accepts any FirestoreService implementation
  ServiceProvider({required FirestoreServiceInterface firestoreService}) : _firestoreService = firestoreService {
    // Initialize services data when provider is created
    initServicesData();
  }
  
  // Getters
  List<ServiceModel> get services => _services;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize services data from Firestore
  void initServicesData() {
    _setLoading(true);
    
    // Cancel any existing subscription
    _servicesSubscription?.cancel();
    
    // Subscribe to services
    _servicesSubscription = _firestoreService.getServices().listen(
      (servicesList) {
        _services = servicesList;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading services: ${error.toString()}');
      }
    );
  }
  
  // Set selected service
  void setSelectedService(String serviceId) {
    try {
      _selectedService = _services.firstWhere((service) => service.id == serviceId);
      notifyListeners();
    } catch (e) {
      _setError('Service not found');
    }
  }
  
  // Generate sample services for development
  Future<void> generateSampleServices() async {
    _setLoading(true);
    
    try {
      await _firestoreService.generateSampleServices();
    } catch (e) {
      _setError('Failed to generate sample services: ${e.toString()}');
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
    _servicesSubscription?.cancel();
    super.dispose();
  }
}
