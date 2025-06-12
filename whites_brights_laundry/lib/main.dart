import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'core/constants.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
// OTP screen removed as we're using email/password auth
import 'features/home/screens/home_screen.dart';
import 'features/main_app_screen.dart';
import 'features/order/screens/schedule_screen.dart';
import 'features/order/screens/order_summary_screen.dart';
import 'features/order/screens/order_tracking/order_status_screen.dart';
import 'features/order/screens/order_history/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';

// Admin Panel screens
import 'features/admin/screens/admin_login_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/user_management_screen.dart';
import 'features/admin/screens/user_detail_screen.dart';
import 'features/admin/screens/order_management_screen.dart';
import 'features/admin/screens/order_detail_screen.dart';
import 'features/admin/screens/service_management_screen.dart';
import 'features/admin/screens/notifications_screen.dart';
import 'features/admin/screens/admin_logs_screen.dart';
import 'features/admin/screens/rider_management_screen.dart';
import 'features/admin/screens/rider_detail_screen.dart';
import 'features/admin/screens/order_assign_rider_screen.dart';
import 'features/admin/screens/rider_analytics_screen.dart';

// Providers
// Providers (use MongoDB-backed implementations)
import 'services/providers/user_provider_mongodb.dart';
import 'services/providers/order_provider_mongodb.dart';
import 'services/providers/address_provider_mongodb.dart';
import 'services/providers/service_provider.dart';
import 'services/providers/auth_provider.dart';
import 'features/admin/providers/admin_provider.dart';


// Services
import 'services/mongodb/api_service.dart';
import 'services/mongodb/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setting preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize MongoDB API service
  final apiService = ApiService();
  await apiService.initialize();
  
  debugPrint('MongoDB API service initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Application providers (ensure these match the imported MongoDB-backed classes)
        ChangeNotifierProvider(create: (_) => UserProvider()), // from user_provider_mongodb.dart
        ChangeNotifierProvider(create: (_) => OrderProvider()), // from order_provider_mongodb.dart
        ChangeNotifierProvider(create: (_) => AddressProvider()), // from address_provider_mongodb.dart
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Fetch services when the app starts (only once)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ServiceProvider>(context, listen: false).fetchServices();
          });
          
          return MaterialApp.router(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

// GoRouter configuration
final _router = GoRouter(
  // Start at the login screen
  initialLocation: AppRoutes.login,
  routes: [
    // Authentication routes
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    // OTP route removed as we're using email/password auth
    
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
        final serviceId = state.extra as String? ?? '1';
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
    
    // Admin panel routes
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin-user-detail',
      builder: (context, state) => const UserDetailScreen(),
    ),
    GoRoute(
      path: '/admin-orders',
      builder: (context, state) => const OrderManagementScreen(),
    ),
    GoRoute(
      path: '/admin-order-detail',
      builder: (context, state) => const OrderDetailScreen(),
    ),
    GoRoute(
      path: '/admin-services',
      builder: (context, state) => const ServiceManagementScreen(),
    ),
    GoRoute(
      path: '/admin-notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/admin-logs',
      builder: (context, state) => const AdminLogsScreen(),
    ),
    GoRoute(
      path: '/admin-riders',
      builder: (context, state) => const RiderManagementScreen(),
    ),
    GoRoute(
      path: '/admin-rider-detail/:riderId',
      builder: (context, state) {
        final riderId = state.pathParameters['riderId'] ?? '';
        return RiderDetailScreen(riderId: riderId);
      },
    ),
    GoRoute(
      path: '/admin-order-assign-rider/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderAssignRiderScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/admin-rider-analytics',
      builder: (context, state) => const RiderAnalyticsScreen(),
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
