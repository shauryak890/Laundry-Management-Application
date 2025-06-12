import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/screens/order_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/service_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/user_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/features/admin/widgets/dashboard_card.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.fetchDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      drawer: const AdminDrawer(selectedIndex: 0),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoadingDashboard) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminProvider.dashboardError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading dashboard',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final dashboardData = adminProvider.dashboardData;
            if (dashboardData == null) {
              return const Center(child: Text('No dashboard data available'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Whites & Brights Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dashboard Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        DashboardCard(
                          title: 'Total Orders',
                          value: dashboardData.totalOrders.toString(),
                          icon: Icons.shopping_bag,
                          color: GlobalColors.primaryColor,
                          onTap: () => context.go('/admin-orders'),
                        ),
                        DashboardCard(
                          title: 'Pending Orders',
                          value: dashboardData.pendingOrders.toString(),
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                          onTap: () => context.go('/admin-orders', extra: {'status': 'scheduled'}),
                        ),
                        DashboardCard(
                          title: 'Completed Orders',
                          value: dashboardData.completedOrders.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                          onTap: () => context.go('/admin-orders', extra: {'status': 'delivered'}),
                        ),
                        DashboardCard(
                          title: 'Total Users',
                          value: dashboardData.totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () => context.go('/admin-users'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Revenue Card
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 32,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Total Revenue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '₹${dashboardData.revenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Action Buttons
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.people,
                          label: 'Users',
                          onPressed: () => context.go('/admin-users'),
                        ),
                        _buildActionButton(
                          icon: Icons.shopping_bag,
                          label: 'Orders',
                          onPressed: () => context.go('/admin-orders'),
                        ),
                        _buildActionButton(
                          icon: Icons.cleaning_services,
                          label: 'Services',
                          onPressed: () => context.go('/admin-services'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Material(
          color: GlobalColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 30,
                color: GlobalColors.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
