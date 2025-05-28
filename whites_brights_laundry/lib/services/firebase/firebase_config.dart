import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration class to determine Firebase availability
class FirebaseConfig {
  // Singleton pattern
  static final FirebaseConfig _instance = FirebaseConfig._internal();
  factory FirebaseConfig() => _instance;
  FirebaseConfig._internal();

  /// Check if Firebase is supported on the current platform
  bool get isFirebaseSupported {
    if (kIsWeb) return true; // Firebase is supported on web
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false; // Not supported on Windows, Linux, etc.
  }

  /// Check if we should use mock services
  bool get shouldUseMockServices {
    // Always use mock services on unsupported platforms
    if (!isFirebaseSupported) return true;
    // For supported platforms, use real Firebase (no mocks) by default
    return false;
  }
}
