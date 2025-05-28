import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants.dart';
import '../../../../models/order_model.dart';
import '../../../../services/providers/order_provider_mongodb.dart';
import 'order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize order data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<OrderProvider>(context, listen: false).refreshOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Completed'),
          ],
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textLight,
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final isLoading = orderProvider.isLoading;
          
          // Filter active orders - include all orders that are not delivered or cancelled
          final activeOrders = orderProvider.orders.where((o) => 
            o.status == OrderStatus.scheduled || 
            o.status == OrderStatus.pickedUp || 
            o.status == OrderStatus.inProcess || 
            o.status == OrderStatus.outForDelivery
          ).toList();
          
          // Filter completed orders - only include delivered orders
          final completedOrders = orderProvider.orders.where((o) => 
            o.status == OrderStatus.delivered
          ).toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Active Orders Tab
              isLoading
                  ? _buildLoadingState()
                  : activeOrders.isEmpty
                      ? _buildEmptyState('No active orders')
                      : _buildOrdersList(activeOrders),
              
              // Completed Orders Tab
              isLoading
                  ? _buildLoadingState()
                  : completedOrders.isEmpty
                      ? _buildEmptyState('No order history found')
                      : _buildOrdersList(completedOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => _navigateToOrderDetails(order.id),
        );
      },
    );
  }

  void _navigateToOrderDetails(String orderId) {
    // Navigate to order details screen
    context.push('/order-status/$orderId');
  }
}
