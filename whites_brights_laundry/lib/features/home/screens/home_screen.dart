import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../services/providers/order_provider.dart';
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
      body: SafeArea(
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
                        // Set the selected service in the provider
                        orderProvider.setSelectedService(service['id']);
                        // Navigate to schedule screen
                        context.push('${AppRoutes.schedule}?serviceId=${service['id']}');
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
    );
  }
}
