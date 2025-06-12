import 'package:flutter/material.dart';

import '../../models/service_model.dart';
import '../mongodb/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  // API service for making HTTP requests
  final ApiService _apiService = ApiService();
  
  // List of services from MongoDB
  final List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  // Basic state variables
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }
  
  // Fetch services from MongoDB
  Future<void> fetchServices() async {
    _setLoading(true);
    
    try {
      debugPrint('Fetching services from MongoDB...');
      final response = await _apiService.get('/services');
      debugPrint('Services response: $response');
      
      final List<ServiceModel> fetchedServices = [];
      if (response['data'] != null && response['data'] is List) {
        for (var serviceData in response['data']) {
          try {
            fetchedServices.add(ServiceModel.fromMap(serviceData));
          } catch (e) {
            debugPrint('Error parsing service: $e');
            debugPrint('Service data: $serviceData');
          }
        }
        
        _services.clear();
        _services.addAll(fetchedServices);
        debugPrint('Fetched ${_services.length} services successfully');
      } else {
        _error = 'Invalid response format';
        debugPrint('Invalid response format: ${response['data']}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching services: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Get service by ID
  ServiceModel? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      debugPrint('Service with ID $id not found');
      return null;
    }
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

  @override
  void dispose() {
    super.dispose();
  }
}
