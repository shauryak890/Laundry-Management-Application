import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../services/providers/user_provider_mongodb.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home/screens/home_screen.dart';
import 'order/screens/order_history/order_history_screen.dart';
import 'order/screens/schedule_screen.dart';
import 'profile/screens/profile_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Initialize user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.initUserData();
        userProvider.streamUserData();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Home Screen
          const HomeScreen(),
          
          // Orders Screen
          const OrderHistoryScreen(),
          
          // Schedule Screen (for adding new orders)
          const ScheduleScreen(serviceId: '1'), // Default to first service
          
          // Profile Screen
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemTapped,
      ),
    );
  }
}
