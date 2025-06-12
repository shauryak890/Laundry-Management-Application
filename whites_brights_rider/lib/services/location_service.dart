import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/rider_model.dart';

class LocationService {
  final StreamController<Location> _locationController = StreamController<Location>.broadcast();
  Stream<Location> get locationStream => _locationController.stream;
  
  Timer? _periodicTimer;
  Location? _lastLocation;
  
  // Default location update interval in seconds
  static const int _defaultUpdateIntervalSeconds = 30;
  
  Future<void> initialize() async {
    await _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      throw LocationServiceException('Location services are disabled');
    }
    
    // Check if we have permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again
        throw LocationServiceException('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      throw LocationServiceException(
          'Location permissions are permanently denied, we cannot request permissions');
    }
  }
  
  Future<Location> getCurrentLocation() async {
    try {
      await _checkPermissions();
      
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _lastLocation = Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      _locationController.add(_lastLocation!);
      return _lastLocation!;
    } catch (e) {
      throw LocationServiceException('Error getting current location: $e');
    }
  }
  
  void startLocationUpdates({int intervalSeconds = _defaultUpdateIntervalSeconds}) {
    // Stop any existing timer
    stopLocationUpdates();
    
    // Start periodic updates
    _periodicTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) async {
        try {
          await getCurrentLocation();
        } catch (e) {
          debugPrint('Error updating location: $e');
        }
      },
    );
  }
  
  void stopLocationUpdates() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
  
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}

class LocationServiceException implements Exception {
  final String message;
  
  LocationServiceException(this.message);
  
  @override
  String toString() => 'LocationServiceException: $message';
}
