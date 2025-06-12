import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/constants/colors.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/models/rider_model.dart';
import 'package:whites_brights_laundry/widgets/custom_button.dart';

class OrderAssignRiderScreen extends StatefulWidget {
  final String orderId;
  final OrderModel? order;
  
  const OrderAssignRiderScreen({
    Key? key,
    required this.orderId,
    this.order,
  }) : super(key: key);

  @override
  State<OrderAssignRiderScreen> createState() => _OrderAssignRiderScreenState();
}

class _OrderAssignRiderScreenState extends State<OrderAssignRiderScreen> {
  bool _isLoading = true;
  bool _isAssigning = false;
  List<RiderModel> _availableRiders = [];
  String? _selectedRiderId;
  String? _errorMessage;
  OrderModel? _order;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      // If order wasn't passed in, fetch it
      if (_order == null) {
        // Fetch order details - this would be implemented in AdminProvider
        // For now, we'll just use a placeholder
        final orders = await adminProvider.fetchOrders(
          status: null,
          userId: null,
          page: 1,
          limit: 100,
        );
        _order = adminProvider.orders.firstWhere(
          (order) => order.id == widget.orderId,
          orElse: () => throw Exception('Order not found'),
        );
      }
      
      // Fetch available riders
      await adminProvider.fetchRiders(isAvailable: true);
      _availableRiders = adminProvider.riders;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _assignRider() async {
    if (_selectedRiderId == null) {
      setState(() {
        _errorMessage = 'Please select a rider';
      });
      return;
    }

    setState(() {
      _isAssigning = true;
      _errorMessage = null;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.assignRiderToOrder(
        widget.orderId,
        _selectedRiderId!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rider assigned successfully')),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isAssigning = false;
            _errorMessage = 'Failed to assign rider';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAssigning = false;
          _errorMessage = 'Error assigning rider: ${e.toString()}';
        });
      }
    }
  }

  void _filterRiders(String query) {
    // This would filter riders based on search query
    // For now, we'll just reload all riders
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Rider to Order'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Order summary card
                if (_order != null)
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${_order!.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${_order!.status.name}'),
                          Text('Customer: ${_order!.userName}'),
                          Text(
                            'Date: ${_order!.createdAt.day}/${_order!.createdAt.month}/${_order!.createdAt.year}',
                          ),
                          Text('Total: \$${_order!.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search riders...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _filterRiders,
                  ),
                ),
                
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                
                // Available riders list
                Expanded(
                  child: _availableRiders.isEmpty
                      ? const Center(child: Text('No available riders found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _availableRiders.length,
                          itemBuilder: (context, index) {
                            final rider = _availableRiders[index];
                            final isSelected = rider.id == _selectedRiderId;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              color: isSelected
                                  ? AppColors.primaryColor.withOpacity(0.1)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: isSelected
                                    ? const BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedRiderId = rider.id;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: AppColors.primaryColor,
                                        backgroundImage: rider.profileImageUrl != null
                                            ? NetworkImage(rider.profileImageUrl!)
                                            : null,
                                        child: rider.profileImageUrl == null
                                            ? Text(
                                                rider.name.substring(0, 1).toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rider.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text('Rating: ${rider.rating}/5.0'),
                                            Text('Completed Orders: ${rider.completedOrders}'),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: rider.id,
                                        groupValue: _selectedRiderId,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedRiderId = value;
                                          });
                                        },
                                        activeColor: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Assign button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    text: 'Assign Rider',
                    onTap: _isAssigning ? null : _assignRider,
                    isLoading: _isAssigning,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
