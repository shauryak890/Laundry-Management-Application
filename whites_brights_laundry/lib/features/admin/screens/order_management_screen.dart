import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/screens/order_detail_screen.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/features/admin/widgets/search_filter_bar.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';
import 'package:whites_brights_laundry/utils/order_utils.dart';

class OrderManagementScreen extends StatefulWidget {
  static const String routeName = '/admin-orders';

  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String? _selectedStatus;
  String? _selectedUserId;
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      // Check if we have arguments for initial filters
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          _selectedStatus = args['status'] as String?;
          _selectedUserId = args['userId'] as String?;
        });
      }
      
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchOrders(
      status: _selectedStatus,
      userId: _selectedUserId,
      page: _currentPage,
      limit: _perPage,
    );
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _fetchOrders();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedUserId = null;
      _currentPage = 1;
    });
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: GlobalColors.primaryColor,
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(selectedIndex: 2),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoadingOrders) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminProvider.ordersError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading orders',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchOrders,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final orders = adminProvider.orders;
            if (orders.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Display active filters
                if (_selectedStatus != null || _selectedUserId != null)
                  SearchFilterBar(
                    filters: {
                      if (_selectedStatus != null) 'Status': _selectedStatus!,
                      if (_selectedUserId != null) 'User ID': _selectedUserId!,
                    },
                    onClear: _clearFilters,
                  ),

                // Orders list
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),

                // Pagination
                if (adminProvider.totalOrders > _perPage)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.navigate_before),
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                  _fetchOrders();
                                }
                              : null,
                        ),
                        Text(
                          'Page $_currentPage of ${(adminProvider.totalOrders / _perPage).ceil()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigate_next),
                          onPressed: _currentPage < (adminProvider.totalOrders / _perPage).ceil()
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                  _fetchOrders();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Determine card border color based on status
    Color statusColor;
    switch (order.status) {
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'pickedUp':
        statusColor = Colors.orange;
        break;
      case 'inProcess':
        statusColor = Colors.purple;
        break;
      case 'outForDelivery':
        statusColor = Colors.amber;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: statusColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            OrderDetailScreen.routeName,
            arguments: order,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      OrderUtils.formatOrderStatus(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Service details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_laundry_service, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.scale, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${order.quantity} ${order.serviceUnit}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Address and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.addressText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUpdateStatusButton(order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateStatusButton(OrderModel order) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Update Status',
      onSelected: (newStatus) async {
        final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        final result = await adminProvider.updateOrderStatus(order.id, newStatus);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result
                    ? 'Order status updated successfully'
                    : 'Failed to update order status',
              ),
              backgroundColor: result ? Colors.green : Colors.red,
            ),
          );
        }
      },
      itemBuilder: (context) {
        return [
          if (order.status != 'scheduled')
            const PopupMenuItem(
              value: 'scheduled',
              child: Text('Scheduled'),
            ),
          if (order.status != 'pickedUp')
            const PopupMenuItem(
              value: 'pickedUp',
              child: Text('Picked Up'),
            ),
          if (order.status != 'inProcess')
            const PopupMenuItem(
              value: 'inProcess',
              child: Text('In Process'),
            ),
          if (order.status != 'outForDelivery')
            const PopupMenuItem(
              value: 'outForDelivery',
              child: Text('Out For Delivery'),
            ),
          if (order.status != 'delivered')
            const PopupMenuItem(
              value: 'delivered',
              child: Text('Delivered'),
            ),
          if (order.status != 'cancelled')
            const PopupMenuItem(
              value: 'cancelled',
              child: Text('Cancelled'),
            ),
        ];
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedStatus != null || _selectedUserId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColors.primaryColor,
              ),
              child: const Text('Clear Filters'),
            ),
          ]
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Status formatting now handled by OrderUtils class

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;

        return AlertDialog(
          title: const Text('Filter Orders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: tempStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...['scheduled', 'pickedUp', 'inProcess', 'outForDelivery', 'delivered', 'cancelled']
                      .map((status) => DropdownMenuItem<String?>(
                            value: status,
                            child: Text(OrderUtils.formatOrderStatus(OrderStatus.values.firstWhere(
                              (s) => s.toString().split('.').last == status,
                              orElse: () => OrderStatus.scheduled,
                            ))),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  tempStatus = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = tempStatus;
                });
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
