import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/rider_provider.dart';
import '../models/order_model.dart';
import '../widgets/analytics_card.dart';
import '../widgets/chart_container.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeFilter = 'week'; // 'day', 'week', 'month'

  @override
  Widget build(BuildContext context) {
    final riderProvider = Provider.of<RiderProvider>(context);
    final orders = riderProvider.allOrders;
    
    // Filter orders based on selected time period
    final filteredOrders = _filterOrdersByTime(orders, _timeFilter);
    
    // Calculate analytics data
    final totalOrders = filteredOrders.length;
    final completedOrders = filteredOrders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders = filteredOrders.where((o) => o.status == OrderStatus.cancelled).length;
    final totalRevenue = _calculateTotalRevenue(filteredOrders);
    final averageRating = _calculateAverageRating(filteredOrders);
    
    return RefreshIndicator(
      onRefresh: () => riderProvider.fetchOrderHistory(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time filter
              _buildTimeFilter(),
              const SizedBox(height: AppSpacing.md),
              
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Total Orders',
                      value: totalOrders.toString(),
                      icon: Icons.assignment,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Completed',
                      value: '$completedOrders',
                      icon: Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Revenue',
                      value: '₹${totalRevenue.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Rating',
                      value: averageRating > 0 ? '${averageRating.toStringAsFixed(1)}/5' : 'N/A',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Order completion chart
              const Text('Order Completion Rate', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              ChartContainer(
                height: 200,
                child: _buildCompletionChart(completedOrders, cancelledOrders, totalOrders),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Revenue chart
              const Text('Revenue Trend', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              ChartContainer(
                height: 200,
                child: _buildRevenueTrendChart(filteredOrders, _timeFilter),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Recent orders
              const Text('Recent Orders', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              _buildRecentOrdersList(filteredOrders),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimeFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'day',
              label: Text('Today'),
            ),
            ButtonSegment<String>(
              value: 'week',
              label: Text('This Week'),
            ),
            ButtonSegment<String>(
              value: 'month',
              label: Text('This Month'),
            ),
          ],
          selected: {_timeFilter},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              setState(() {
                _timeFilter = selection.first;
              });
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildCompletionChart(int completed, int cancelled, int total) {
    if (total == 0) {
      return const Center(child: Text('No orders in selected period'));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPieChartSegment('Completed', completed, total, AppTheme.successColor),
        _buildPieChartSegment('Cancelled', cancelled, total, Colors.red),
        _buildPieChartSegment('In Progress', total - completed - cancelled, total, Colors.orange),
      ],
    );
  }
  
  Widget _buildPieChartSegment(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: total > 0 ? value / total : 0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 10,
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label),
        Text('$value orders', style: const TextStyle(color: AppTheme.lightTextColor)),
      ],
    );
  }
  
  Widget _buildRevenueTrendChart(List<OrderModel> orders, String timeFilter) {
    if (orders.isEmpty) {
      return const Center(child: Text('No revenue data in selected period'));
    }
    
    // Simple placeholder for revenue chart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 60, color: AppTheme.primaryColor),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Total Revenue: ₹${_calculateTotalRevenue(orders).toStringAsFixed(0)}',
            style: AppTextStyles.heading3,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text('No orders in the selected period'),
          ),
        ),
      );
    }
    
    // Sort by date, most recent first
    final sortedOrders = List<OrderModel>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Take only the 5 most recent
    final recentOrders = sortedOrders.take(5).toList();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentOrders.length,
      itemBuilder: (context, index) {
        final order = recentOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status),
              child: Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
              ),
            ),
            title: Text('Order #${order.orderNumber}'),
            subtitle: Text(
              '${_formatDate(order.createdAt)} • ₹${order.totalAmount.toStringAsFixed(0)}',
            ),
            trailing: _getStatusChip(order.status),
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppTheme.successColor;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.inProgress:
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
  
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.inProgress:
        return Icons.local_shipping;
      default:
        return Icons.assignment;
    }
  }
  
  Widget _getStatusChip(OrderStatus status) {
    return Chip(
      label: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  List<OrderModel> _filterOrdersByTime(List<OrderModel> orders, String timeFilter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return orders.where((order) {
      final orderDate = order.createdAt;
      
      switch (timeFilter) {
        case 'day':
          return orderDate.isAfter(today);
        case 'week':
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          return orderDate.isAfter(weekStart);
        case 'month':
          final monthStart = DateTime(now.year, now.month, 1);
          return orderDate.isAfter(monthStart);
        default:
          return true;
      }
    }).toList();
  }
  
  double _calculateTotalRevenue(List<OrderModel> orders) {
    return orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0, (sum, order) => sum + order.totalAmount);
  }
  
  double _calculateAverageRating(List<OrderModel> orders) {
    final ratedOrders = orders.where((o) => o.rating != null && o.rating! > 0);
    if (ratedOrders.isEmpty) return 0;
    
    final totalRating = ratedOrders.fold(0.0, (sum, order) => sum + (order.rating ?? 0));
    return totalRating / ratedOrders.length;
  }
}
