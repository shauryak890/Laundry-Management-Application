// This file provides platform-specific imports for Firebase
// It will use the real Firebase implementation on supported platforms
// and the stub implementation on unsupported platforms like Windows

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Import the stub implementation
import 'firebase_stub.dart' as stub;

// Since conditional imports are not working reliably for this case,
// we'll use runtime detection instead in the FirebaseImports class below

// Import real Firebase implementations for supported platforms
import 'firebase_real.dart' as real;

// Helper class to determine which implementation to use
class FirebaseImports {
  static bool get isFirebaseSupported {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false;
  }
  
  // Get the appropriate Firebase implementation based on platform
  static dynamic get Firebase {
    try {
      if (isFirebaseSupported) {
        return real.Firebase;
      } else {
        return stub.Firebase;
      }
    } catch (e) {
      // Fallback to stub if there's an error with real implementation
      return stub.Firebase;
    }
  }
  
  // Get the appropriate FirebaseAuth implementation based on platform
  static dynamic get FirebaseAuth {
    try {
      if (isFirebaseSupported) {
        return real.FirebaseAuth;
      } else {
        return stub.FirebaseAuth;
      }
    } catch (e) {
      // Fallback to stub if there's an error with real implementation
      return stub.FirebaseAuth;
    }
  }
  
  // Get the appropriate FirebaseFirestore implementation based on platform
  static dynamic get FirebaseFirestore {
    try {
      if (isFirebaseSupported) {
        return real.FirebaseFirestore;
      } else {
        return stub.FirebaseFirestore;
      }
    } catch (e) {
      // Fallback to stub if there's an error with real implementation
      return stub.FirebaseFirestore;
    }
  }
  
  // Get the appropriate FirebaseStorage implementation based on platform
  static dynamic get FirebaseStorage {
    try {
      if (isFirebaseSupported) {
        return real.FirebaseStorage;
      } else {
        return stub.FirebaseStorage;
      }
    } catch (e) {
      // Fallback to stub if there's an error with real implementation
      return stub.FirebaseStorage;
    }
  }
  
  // Get the appropriate FirebaseMessaging implementation based on platform
  static dynamic get FirebaseMessaging {
    try {
      if (isFirebaseSupported) {
        return real.FirebaseMessaging;
      } else {
        return stub.FirebaseMessaging;
      }
    } catch (e) {
      // Fallback to stub if there's an error with real implementation
      return stub.FirebaseMessaging;
    }
  }
}
