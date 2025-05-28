import 'package:flutter/material.dart';

class ServiceProvider extends ChangeNotifier {
  // List of services with updated prices
  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Wash & Fold',
      'unit': 'kg',
      'price': 199,
      'color': '#2196F3',
    },
    {
      'id': 2,
      'name': 'Dry Clean',
      'unit': 'piece',
      'price': 349,
      'color': '#FFC107',
    },
    {
      'id': 3,
      'name': 'Ironing',
      'unit': 'item',
      'price': 99,
      'color': '#4CAF50',
    },
    {
      'id': 4,
      'name': 'Premium Wash',
      'unit': 'kg',
      'price': 499,
      'color': '#9C27B0',
    },
  ];
  List<Map<String, dynamic>> get services => _services;

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
