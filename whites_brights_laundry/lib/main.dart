import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'core/constants.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/order/screens/schedule_screen.dart';
import 'features/order/screens/order_summary_screen.dart';
import 'features/profile/screens/profile_screen.dart';

import 'services/auth_service.dart';
import 'services/providers/auth_provider.dart';
import 'services/providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setting preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase in a production app
  // await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
  // Start directly at the home screen for development
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final phoneNumber = state.queryParameters['phone'] ?? '';
        return OTPScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.schedule,
      builder: (context, state) {
        final serviceId = int.tryParse(state.queryParameters['serviceId'] ?? '0') ?? 0;
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
