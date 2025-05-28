import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF1976D2);
  static const accentYellow = Color(0xFFFFC107);
  static const textDark = Color(0xFF263238);
  static const textLight = Color(0xFF78909C);
  static const errorRed = Color(0xFFD32F2F);
  static const successGreen = Color(0xFF388E3C);
}

class AppAssets {
  // Service Icons
  static const washFoldIcon = 'assets/images/wash_fold.png';
  static const dryCleanIcon = 'assets/images/dry_clean.png';
  static const ironingIcon = 'assets/images/ironing.png';
  static const premiumWashIcon = 'assets/images/premium_wash.png';
  
  // Animation Assets
  static const successAnimation = 'assets/animations/success.json';
  static const loadingAnimation = 'assets/animations/loading.json';
}

class AppSizes {
  static const double pagePadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 12.0;
  static const double iconSize = 24.0;
}

class AppStrings {
  static const appName = 'Whites & Brights';
  static const welcome = 'Welcome to Whites & Brights';
  static const tagline = 'Your clothes deserve the best care';
  static const login = 'Login';
  static const phoneVerification = 'Phone Verification';
  static const enterPhone = 'Enter your phone number';
  static const verifyOTP = 'Verify OTP';
  static const enterOTP = 'Enter the 6-digit code sent to your phone';
  static const verifyPhone = 'Verify Phone';
  static const phoneHint = '10-digit mobile number';
  static const otpHint = '6-digit OTP';
  static const continueText = 'Continue';
  static const resendOTP = 'Resend OTP';
  static const welcomeBack = 'Welcome back';
  static const services = 'Our Services';
  static const schedule = 'Schedule Pickup & Delivery';
  static const orderSummary = 'Order Summary';
  static const profile = 'My Profile';
  static const placeOrder = 'Place Order';
  static const editProfile = 'Edit Profile';
  static const manageAddresses = 'Manage Addresses';
  static const addAddress = 'Add New Address';
  static const confirmSchedule = 'Confirm Schedule';
}

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  // OTP route removed as we're using email/password auth
  static const home = '/home';
  static const schedule = '/schedule';
  static const orderSummary = '/order-summary';
  static const profile = '/profile';
}

// Sample data for services
class ServiceData {
  static List<Map<String, dynamic>> services = [
    {
      'id': 1,
      'name': 'Wash & Fold',
      'icon': AppAssets.washFoldIcon,
      'price': 199.0,
      'unit': 'kg',
      'color': const Color(0xFFE3F2FD),
    },
    {
      'id': 2,
      'name': 'Dry Clean',
      'icon': AppAssets.dryCleanIcon,
      'price': 349.0,
      'unit': 'item',
      'color': const Color(0xFFFFF9C4),
    },
    {
      'id': 3,
      'name': 'Ironing',
      'icon': AppAssets.ironingIcon,
      'price': 99.0,
      'unit': 'item',
      'color': const Color(0xFFE8F5E9),
    },
    {
      'id': 4,
      'name': 'Premium Wash',
      'icon': AppAssets.premiumWashIcon,
      'price': 499.0,
      'unit': 'kg',
      'color': const Color(0xFFFFECB3),
    },
  ];
}
