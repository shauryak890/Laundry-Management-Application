import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/screens/admin_dashboard_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/admin_login_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/admin_logs_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/notifications_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/order_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/service_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/user_management_screen.dart';
import 'package:whites_brights_laundry/features/admin/screens/rider_management_screen.dart';
import 'package:whites_brights_laundry/services/providers/auth_provider.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;

  const AdminDrawer({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.name ?? 'Admin User',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name ?? 'A')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GlobalColors.primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: GlobalColors.primaryColor,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
            route: '/admin-dashboard',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Users',
            index: 1,
            route: '/admin-users',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_bag,
            title: 'Orders',
            index: 2,
            route: '/admin-orders',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.cleaning_services,
            title: 'Services',
            index: 3,
            route: '/admin-services',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.delivery_dining,
            title: 'Riders',
            index: 4,
            route: '/admin-riders',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Rider Analytics',
            index: 5,
            route: '/admin-rider-analytics',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            index: 6,
            route: '/admin-notifications',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Admin Logs',
            index: 6,
            route: '/admin-logs',
          ),
          const Spacer(),
          const Divider(thickness: 1),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/admin-login');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required String route,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? GlobalColors.primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? GlobalColors.primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? GlobalColors.primaryColor.withOpacity(0.1) : null,
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
