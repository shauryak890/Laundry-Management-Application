import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/rider_provider.dart';
import 'services/api_service.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final apiService = ApiService();
  final locationService = LocationService();
  await locationService.initialize().catchError((e) {
    debugPrint('Error initializing location service: $e');
  });
  
  runApp(MyApp(
    apiService: apiService,
    locationService: locationService,
  ));
}

class MyApp extends StatefulWidget {
  final ApiService apiService;
  final LocationService locationService;
  
  const MyApp({
    Key? key,
    required this.apiService,
    required this.locationService,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final AuthProvider _authProvider;
  
  @override
  void initState() {
    super.initState();
    
    _authProvider = AuthProvider(
      apiService: widget.apiService,
    );
    
    _router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) async {
        final isLoggedIn = _authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }
        if (isLoggedIn && isLoginRoute) {
          return '/home';
        }
        
        return null;
      },
      refreshListenable: _authProvider,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
    
    // Check authentication status when app starts
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    await _authProvider.checkAuthStatus();
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: _authProvider,
        ),
        ChangeNotifierProvider<RiderProvider>(
          create: (context) => RiderProvider(
            apiService: widget.apiService,
            locationService: widget.locationService,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Whites & Brights Rider',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}


