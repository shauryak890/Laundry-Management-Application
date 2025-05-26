import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_config.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';

import 'core/theme.dart';
import 'core/constants.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/main_app_screen.dart';
import 'features/order/screens/schedule_screen.dart';
import 'features/order/screens/order_summary_screen.dart';
import 'features/order/screens/order_tracking/order_status_screen.dart';
import 'features/order/screens/order_history/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';

// Firebase services
import 'services/firebase/firebase_service.dart';
import 'services/firebase/notification_service.dart';
import 'services/firebase/firebase_service_factory.dart';

// Providers
import 'services/providers/auth_provider.dart';
import 'services/providers/order_provider.dart';
import 'services/providers/order_provider_firebase.dart';
import 'services/providers/user_provider.dart';
import 'services/providers/address_provider.dart';
import 'services/providers/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setting preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Get the Firebase service factory
  final firebaseServiceFactory = FirebaseServiceFactory();
  final firebaseConfig = FirebaseConfig();
  
  // Set to use mock services based on platform support and development mode
  firebaseServiceFactory.useMockServices = firebaseConfig.shouldUseMockServices;
  
  // Initialize Firebase services
  try {
    // Always use mock services for Windows development
    debugPrint('Using mock Firebase services for Windows development');
    
    // Initialize Firebase with our mock implementation
    await Firebase.initializeApp();
    await FirebaseService.initializeFirebase();
    
    // Create sample data for development
    final firestoreService = FirebaseService.instance.firestore;
    
    // Generate some sample services and riders (for first run)
    if (Platform.isWindows) {
      debugPrint('Generating sample data for Windows development');
      // Sample data is populated in the FirebaseService._initializeMockData method
    }
  } catch (e) {
    debugPrint('Error initializing Firebase services: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Legacy providers for development without Firebase
        ChangeNotifierProvider(create: (_) {
          // For development, create an already logged-in AuthProvider
          final provider = AuthProvider();
          provider.updateUserProfile(name: 'John Doe');
          // Simulate logged in state for development
          provider.setDevLoginState(true);
          return provider;
        }),
        ChangeNotifierProvider(create: (_) {
          // Initialize order provider with sample addresses
          final provider = OrderProvider();
          if (provider.savedAddresses.isEmpty) {
            provider.addAddress('123 Main St, Apartment 4B, City, State, 12345');
            provider.addAddress('456 Park Avenue, Building 7, City, State, 67890');
          }
          return provider;
        }),
        
        // Firebase-based providers
        ChangeNotifierProvider(create: (_) {
          final authService = FirebaseServiceFactory().getAuthService();
          return UserProvider(authService: authService);
        }),
        ChangeNotifierProvider(create: (_) {
          final firestoreService = FirebaseServiceFactory().getFirestoreService();
          return OrderProviderFirebase(firestoreService: firestoreService);
        }),
        ChangeNotifierProvider(create: (_) {
          final firestoreService = FirebaseServiceFactory().getFirestoreService();
          return AddressProvider(firestoreService: firestoreService);
        }),
        ChangeNotifierProvider(create: (_) {
          final firestoreService = FirebaseServiceFactory().getFirestoreService();
          return ServiceProvider(firestoreService: firestoreService);
        }),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

// GoRouter configuration
final _router = GoRouter(
  // Start directly at the main app screen for development
  initialLocation: '/main',
  routes: [
    // Authentication routes
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return OTPScreen(phoneNumber: phoneNumber);
      },
    ),
    
    // Main application with bottom navigation
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainAppScreen(),
    ),
    
    // Individual screens (for deep linking and direct navigation)
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.schedule,
      builder: (context, state) {
        final serviceId = state.extra as int? ?? 0;
        return ScheduleScreen(serviceId: serviceId);
      },
    ),
    GoRoute(
      path: AppRoutes.orderSummary,
      builder: (context, state) => const OrderSummaryScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // New routes for order tracking and history
    GoRoute(
      path: '/order-status/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderStatusScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-history',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
  ],
  // Disable auth redirects for development
  /* 
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;
    
    final isLoginRoute = state.location == AppRoutes.login || 
                          state.location == AppRoutes.otp;
    
    // If not logged in and not on login routes, redirect to login
    if (!isLoggedIn && !isLoginRoute) {
      return AppRoutes.login;
    }
    
    // If logged in and on login routes, redirect to home
    if (isLoggedIn && isLoginRoute) {
      return AppRoutes.home;
    }
    
    // No redirect needed
    return null;
  },
  */
);
