import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rider_provider.dart';
import '../widgets/order_card.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _statusOptions = ['available', 'busy', 'offline'];
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // Use a post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final riderProvider = Provider.of<RiderProvider>(context, listen: false);
      
      if (authProvider.riderId != null) {
        riderProvider.fetchRiderProfile(authProvider.riderId!);
        riderProvider.fetchAssignedOrders(authProvider.riderId!);
        riderProvider.startOrdersPolling(authProvider.riderId!);
        riderProvider.startLocationTracking();
      }
    });
  }
  
  @override
  void dispose() {
    final riderProvider = Provider.of<RiderProvider>(context, listen: false);
    riderProvider.stopOrdersPolling();
    riderProvider.stopLocationTracking();
    super.dispose();
  }
  
  Future<void> _updateRiderStatus(String status) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final riderProvider = Provider.of<RiderProvider>(context, listen: false);
    
    if (authProvider.riderId != null) {
      await riderProvider.updateRiderStatus(authProvider.riderId!, status);
    }
  }
  
  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final riderProvider = Provider.of<RiderProvider>(context, listen: false);
    
    if (authProvider.riderId != null) {
      await riderProvider.fetchRiderProfile(authProvider.riderId!);
      await riderProvider.fetchAssignedOrders(authProvider.riderId!);
    }
  }
  
  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  Widget _buildStatusSelector() {
    final riderProvider = Provider.of<RiderProvider>(context);
    final currentStatus = riderProvider.rider?.status ?? 'offline';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Status',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'available',
                  label: const Text('Available'),
                  icon: const Icon(Icons.check_circle),
                ),
                ButtonSegment<String>(
                  value: 'busy',
                  label: const Text('Busy'),
                  icon: const Icon(Icons.access_time),
                ),
                ButtonSegment<String>(
                  value: 'offline',
                  label: const Text('Offline'),
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
              selected: {currentStatus},
              onSelectionChanged: (Set<String> selection) {
                if (selection.isNotEmpty) {
                  _updateRiderStatus(selection.first);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppTheme.primaryColor;
                    }
                    return Colors.transparent;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderList() {
    return Consumer<RiderProvider>(
      builder: (context, riderProvider, child) {
        if (riderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (riderProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${riderProvider.error}',
                  style: const TextStyle(color: AppTheme.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (riderProvider.assignedOrders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppTheme.lightTextColor,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No orders assigned to you yet',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Check back later or contact your manager',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        // Separate orders by status for better organization
        final activeOrders = riderProvider.assignedOrders
            .where((order) => 
                order.status != OrderStatus.delivered && 
                order.status != OrderStatus.cancelled)
            .toList();
            
        final completedOrders = riderProvider.assignedOrders
            .where((order) => 
                order.status == OrderStatus.delivered || 
                order.status == OrderStatus.cancelled)
            .toList();
        
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (activeOrders.isNotEmpty) ...[
                const Text(
                  'Active Orders',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.md),
                ...activeOrders.map((order) => OrderCard(
                  order: order,
                  onStatusUpdate: (OrderStatus status) async {
                    await riderProvider.updateOrderStatus(order.id, status);
                  },
                )),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (completedOrders.isNotEmpty) ...[
                const Text(
                  'Completed Orders',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.md),
                ...completedOrders.map((order) => OrderCard(
                  order: order,
                  isCompleted: true,
                  onStatusUpdate: null, // No updates for completed orders
                )),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildProfileSection() {
    return Consumer2<AuthProvider, RiderProvider>(
      builder: (context, auth, rider, _) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.lg),
            
            // Profile avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  auth.name?.isNotEmpty == true
                      ? auth.name!.substring(0, 1).toUpperCase()
                      : 'R',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Rider name
            Text(
              auth.name ?? 'Rider',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Rider status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rider.rider?.status == 'available'
                        ? AppTheme.successColor
                        : rider.rider?.status == 'busy'
                            ? AppTheme.warningColor
                            : AppTheme.lightTextColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  rider.rider?.status ?? 'Offline',
                  style: const TextStyle(
                    color: AppTheme.lightTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Profile info
            const Text(
              'Profile Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildProfileInfoItem('Email', auth.email ?? 'Not available'),
            _buildProfileInfoItem('Phone', auth.phoneNumber ?? 'Not available'),
            _buildProfileInfoItem('Active Orders', (rider.rider?.activeOrderCount ?? 0).toString()),
            
            if (rider.rider?.averageRating != null && rider.rider!.averageRating > 0)
              _buildProfileInfoItem('Rating', '${rider.rider!.averageRating.toStringAsFixed(1)}/5'),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Logout button
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildProfileInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildOrderList(),
      const AnalyticsScreen(),
      _buildProfileSection(),
    ];
    
    final auth = Provider.of<AuthProvider>(context);
    final riderProvider = Provider.of<RiderProvider>(context, listen: false);
    
    // Fetch order history for analytics when analytics tab is selected
    if (_currentIndex == 1 && !riderProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        riderProvider.fetchOrderHistory();
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whites & Brights Rider'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_currentIndex == 0) _buildStatusSelector(),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
