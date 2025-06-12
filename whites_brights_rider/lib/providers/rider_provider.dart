import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/rider_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class RiderProvider with ChangeNotifier {
  final ApiService _apiService;
  final LocationService _locationService;
  
  RiderModel? _rider;
  List<OrderModel> _assignedOrders = [];
  List<OrderModel> _orderHistory = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Location>? _locationSubscription;
  
  // Analytics data
  double _totalRevenue = 0;
  double _weeklyRevenue = 0;
  double _monthlyRevenue = 0;
  double _averageRating = 0;
  int _totalCompletedOrders = 0;
  
  // For orders polling
  Timer? _ordersTimer;
  static const int _ordersPollingInterval = 30; // seconds
  
  RiderProvider({
    ApiService? apiService, 
    LocationService? locationService
  }) : 
    _apiService = apiService ?? ApiService(),
    _locationService = locationService ?? LocationService() {
    // Initialize location service
    _locationService.initialize().catchError((e) {
      _error = 'Location service initialization failed: $e';
      notifyListeners();
    });
    
    // Listen to location updates
    _locationSubscription = _locationService.locationStream.listen(_onLocationUpdate);
  }
  
  // Getters
  RiderModel? get rider => _rider;
  List<OrderModel> get assignedOrders => _assignedOrders;
  List<OrderModel> get orderHistory => _orderHistory;
  List<OrderModel> get allOrders => [..._assignedOrders, ..._orderHistory];
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLocationTracking => _locationSubscription != null;
  
  // Analytics getters
  double get totalRevenue => _totalRevenue;
  double get weeklyRevenue => _weeklyRevenue;
  double get monthlyRevenue => _monthlyRevenue;
  double get averageRating => _averageRating;
  int get totalCompletedOrders => _totalCompletedOrders;
  
  // Get rider profile by ID
  Future<void> fetchRiderProfile(String riderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/riders/$riderId');
      _rider = RiderModel.fromJson(response['data']);
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load rider profile';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get all assigned orders for a rider
  Future<void> fetchAssignedOrders(String riderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/riders/$riderId/orders');
      final List ordersJson = response['data'];
      
      _assignedOrders = ordersJson
          .map((orderJson) => OrderModel.fromJson(orderJson))
          .toList();
      
      // Set current order if available
      _currentOrder = _assignedOrders
          .where((order) => 
              order.status != OrderStatus.delivered && 
              order.status != OrderStatus.cancelled)
          .toList()
          .firstOrNull;
          
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load assigned orders';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update rider status (available, busy, offline)
  Future<void> updateRiderStatus(String riderId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Ensure we're using the correct API endpoint format
      final response = await _apiService.put('/api/riders/$riderId/status', {
        'status': newStatus
      });
      
      if (_rider != null) {
        _rider = _rider!.copyWith(status: newStatus);
      }
      
      debugPrint('Rider status updated successfully: $newStatus');
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to update rider status: $e';
      debugPrint('Error updating rider status: $_error');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Ensure we're using the correct API endpoint format
      final response = await _apiService.put('/api/orders/$orderId/status', {
        'status': newStatus.value
      });
      
      debugPrint('Order status updated successfully: ${newStatus.value}');
      
      // Update local state
      _updateLocalOrderStatus(orderId, newStatus);
      
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to update order status: $e';
      debugPrint('Error updating order status: $_error');
      
      // Still update local state to improve UX even if API fails
      // This can be removed if you want strict consistency with backend
      _updateLocalOrderStatus(orderId, newStatus);
      
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _updateLocalOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = _assignedOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex >= 0) {
      final updatedOrder = _assignedOrders[orderIndex].updateStatus(newStatus);
      _assignedOrders[orderIndex] = updatedOrder;
      
      // If this is the current order, update it too
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      
      // If delivered/cancelled, make current order null
      if (newStatus == OrderStatus.delivered || newStatus == OrderStatus.cancelled) {
        if (_currentOrder?.id == orderId) {
          _currentOrder = null;
          
          // Find next active order if any
          _currentOrder = _assignedOrders
              .where((order) => 
                  order.id != orderId &&
                  order.status != OrderStatus.delivered && 
                  order.status != OrderStatus.cancelled)
              .toList()
              .firstOrNull;
        }
      }
    }
  }
  
  // Start location tracking and periodic updates
  Future<void> startLocationTracking() async {
    try {
      await _locationService.initialize();
      _locationService.startLocationUpdates();
      
      // Initial location update
      final initialLocation = await _locationService.getCurrentLocation();
      _onLocationUpdate(initialLocation);
    } catch (e) {
      _error = 'Failed to start location tracking: $e';
      notifyListeners();
    }
  }
  
  // Stop location tracking
  void stopLocationTracking() {
    _locationService.stopLocationUpdates();
  }
  
  // Handle location updates
  Future<void> _onLocationUpdate(Location location) async {
    if (_rider != null) {
      try {
        // Update location on server
        await _apiService.put('/riders/${_rider!.id}/location', {
          'latitude': location.latitude,
          'longitude': location.longitude
        });
        
        // Update local rider model
        _rider = _rider!.copyWith(
          location: location.copyWith(lastUpdated: DateTime.now()),
        );
        
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to update location on server: $e');
        // Don't notify as this is a background operation
      }
    }
  }
  
  // Start polling for orders
  void startOrdersPolling(String riderId) {
    stopOrdersPolling();
    
    // Initial fetch
    fetchAssignedOrders(riderId);
    
    // Set up periodic polling
    _ordersTimer = Timer.periodic(
      Duration(seconds: _ordersPollingInterval),
      (_) => fetchAssignedOrders(riderId),
    );
  }
  
  // Stop polling for orders
  void stopOrdersPolling() {
    _ordersTimer?.cancel();
    _ordersTimer = null;
  }
  
  // Fetch order history for analytics
  Future<void> fetchOrderHistory() async {
    if (_rider == null || _rider?.id == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/riders/${_rider!.id}/history');
      final List ordersJson = response['data'] ?? [];
      
      _orderHistory = ordersJson
          .map((orderJson) => OrderModel.fromJson(orderJson))
          .toList();
      
      // Calculate analytics
      _calculateAnalytics();
      
      notifyListeners();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Failed to load order history';
      debugPrint('Error fetching order history: $_error');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Calculate analytics from order history
  void _calculateAnalytics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    
    // All completed orders
    final completedOrders = _orderHistory
        .where((order) => order.status == OrderStatus.delivered)
        .toList();
    
    // Calculate total revenue
    _totalRevenue = completedOrders.fold(0, (sum, order) => sum + order.totalAmount);
    
    // Calculate weekly revenue
    _weeklyRevenue = completedOrders
        .where((order) => order.createdAt.isAfter(weekStart))
        .fold(0, (sum, order) => sum + order.totalAmount);
    
    // Calculate monthly revenue
    _monthlyRevenue = completedOrders
        .where((order) => order.createdAt.isAfter(monthStart))
        .fold(0, (sum, order) => sum + order.totalAmount);
    
    // Calculate average rating
    final ratedOrders = completedOrders.where((o) => o.rating != null && o.rating! > 0);
    if (ratedOrders.isNotEmpty) {
      final totalRating = ratedOrders.fold(0.0, (sum, order) => sum + (order.rating ?? 0));
      _averageRating = totalRating / ratedOrders.length;
    } else {
      _averageRating = 0;
    }
    
    // Total completed orders
    _totalCompletedOrders = completedOrders.length;
  }
  
  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    stopOrdersPolling();
    super.dispose();
  }
}
