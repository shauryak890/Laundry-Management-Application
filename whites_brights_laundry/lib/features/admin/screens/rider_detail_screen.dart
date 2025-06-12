import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/constants/colors.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/models/rider_model.dart';
import 'package:whites_brights_laundry/widgets/custom_button.dart';

class RiderDetailScreen extends StatefulWidget {
  final String riderId;
  
  const RiderDetailScreen({
    Key? key,
    required this.riderId,
  }) : super(key: key);

  @override
  State<RiderDetailScreen> createState() => _RiderDetailScreenState();
}

class _RiderDetailScreenState extends State<RiderDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  RiderModel? _rider;
  List<OrderModel> _assignedOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRiderData();
  }

  Future<void> _loadRiderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get rider details from AdminProvider
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final rider = await adminProvider.getRiderById(widget.riderId);
      final assignedOrders = await adminProvider.getRiderAssignedOrders(widget.riderId);

      if (mounted) {
        setState(() {
          _rider = rider;
          _assignedOrders = assignedOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rider data: ${e.toString()}')),
        );
      }
    }
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
        title: Text(_rider?.name ?? 'Rider Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRiderData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Assigned Orders'),
            Tab(text: 'Location'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rider == null
              ? const Center(child: Text('Rider not found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildOrdersTab(),
                    _buildLocationTab(),
                  ],
                ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rider Profile Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor,
                      backgroundImage: _rider?.profileImageUrl != null
                          ? NetworkImage(_rider!.profileImageUrl!)
                          : null,
                      child: _rider?.profileImageUrl == null
                          ? Text(
                              _rider!.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _rider!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _rider!.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _rider!.isAvailable ? 'Available' : 'Unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoRow(Icons.phone, 'Phone', _rider!.phone),
                  if (_rider!.email != null && _rider!.email!.isNotEmpty)
                    _infoRow(Icons.email, 'Email', _rider!.email!),
                  _infoRow(Icons.star, 'Rating', '${_rider!.rating} / 5.0'),
                  _infoRow(
                    Icons.delivery_dining,
                    'Completed Orders',
                    _rider!.completedOrders.toString(),
                  ),
                  _infoRow(
                    Icons.calendar_today,
                    'Joined',
                    '${_rider!.createdAt.day}/${_rider!.createdAt.month}/${_rider!.createdAt.year}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: _rider!.isAvailable ? 'Set Unavailable' : 'Set Available',
                  onTap: () async {
                    try {
                      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                      await adminProvider.updateRiderAvailability(
                        widget.riderId,
                        !_rider!.isAvailable,
                      );
                      _loadRiderData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating rider: ${e.toString()}')),
                      );
                    }
                  },
                  backgroundColor: _rider!.isAvailable ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Edit Profile',
                  onTap: () {
                    // Navigate to edit rider screen
                    // Will implement this in a future update
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_assignedOrders.isEmpty) {
      return const Center(child: Text('No orders assigned to this rider'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assignedOrders.length,
      itemBuilder: (context, index) {
        final order = _assignedOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text('Order #${order.id.substring(0, 8)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${order.status.name}'),
                Text('Customer: ${order.userName}'),
                Text('Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                // Navigate to order details
                // Will implement this in a future update
              },
            ),
            onTap: () {
              // Navigate to order details
              // Will implement this in a future update
            },
          ),
        );
      },
    );
  }

  Widget _buildLocationTab() {
    if (_rider?.location == null) {
      return const Center(child: Text('Location data not available'));
    }

    // In a real implementation, this would be a Google Map showing the rider's location
    // For now, we'll just show the coordinates
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 80,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Last Known Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${_rider!.location!.latitude}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Longitude: ${_rider!.location!.longitude}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Refresh Location',
            onTap: _loadRiderData,
            width: 200,
          ),
        ],
      ),
    );
  }
}
