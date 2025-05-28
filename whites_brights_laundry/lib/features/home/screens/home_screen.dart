import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../services/providers/order_provider_mongodb.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0, // Home tab
        onItemSelected: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Orders
              context.push('/order-history');
              break;
            case 2: // Schedule
              // Navigate to schedule with a default service
              context.push(AppRoutes.schedule, extra: 1);
              break;
            case 3: // Profile
              context.push(AppRoutes.profile);
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Welcome section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.welcomeBack}, ${authProvider.userName}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'What would you like to clean today?',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Services heading
                          Text(
                            AppStrings.services,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  
                  // Services grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = ServiceData.services[index];
                          return ServiceCard(
                            id: service['id'],
                            name: service['name'],
                            icon: Icons.local_laundry_service, // Using a placeholder icon
                            price: service['price'],
                            unit: service['unit'],
                            color: service['color'],
                            onTap: () {
                              // Instead of directly navigating, use Future.microtask to separate state update from navigation
                              Future.microtask(() {
                                // Set the selected service in the provider
                                orderProvider.setSelectedService(service['id']);
                                // Navigate to schedule screen with only the service ID
                                context.push(AppRoutes.schedule, extra: service['id']);
                              });
                            },
                          );
                        },
                        childCount: ServiceData.services.length,
                      ),
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
            
            // Footer
            // const AppFooter(), // Removed because AppFooter does not exist
          ],
        ),
      ),
    );
  }
}
