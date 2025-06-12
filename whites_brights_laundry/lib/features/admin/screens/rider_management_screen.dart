import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/features/admin/widgets/search_filter_bar.dart';
import 'package:whites_brights_laundry/models/rider_model.dart';
import 'package:whites_brights_laundry/constants/colors.dart';

class RiderManagementScreen extends StatefulWidget {
  static const String routeName = '/admin-riders';
  
  const RiderManagementScreen({Key? key}) : super(key: key);

  @override
  State<RiderManagementScreen> createState() => _RiderManagementScreenState();
}

class _RiderManagementScreenState extends State<RiderManagementScreen> {
  String? _searchQuery;
  String? _statusFilter;
  int _currentPage = 1;
  final int _pageSize = 10;
  
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRiders();
    });
  }

  Future<void> _loadRiders() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.fetchRiders(
        search: _searchQuery,
        isAvailable: _statusFilter == 'available' ? true : _statusFilter == 'offline' ? false : null,
        page: _currentPage,
        limit: _pageSize,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading riders: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String? query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _loadRiders();
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _statusFilter = status;
      _currentPage = 1;
    });
    _loadRiders();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadRiders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Management'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRiderDialog(context),
            tooltip: 'Add New Rider',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRiders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AdminDrawer(selectedIndex: 6), // Adjust index as needed
      body: Column(
        children: [
          // Search and filter bar
          if (_searchQuery != null || _statusFilter != null)
            SearchFilterBar(
              searchTerm: _searchQuery,
              status: _statusFilter,
              onClear: () {
                setState(() {
                  _searchQuery = null;
                  _statusFilter = null;
                });
                _loadRiders();
              },
              onSearchChanged: _onSearchChanged,
              onFilterChanged: _onStatusFilterChanged,
            ),
          
          // Status filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('all'),
                  _buildStatusChip('available'),
                  _buildStatusChip('busy'),
                  _buildStatusChip('offline'),
                ],
              ),
            ),
          ),
          
          // Riders list
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoadingRiders) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (adminProvider.ridersError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${adminProvider.ridersError}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRiders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (adminProvider.riders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No riders found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add a new rider to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddRiderDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Rider'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final riders = adminProvider.riders;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: riders.length,
                        itemBuilder: (context, index) {
                          final rider = riders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(rider.status),
                                child: Text(
                                  rider.name.isNotEmpty ? rider.name[0].toUpperCase() : 'R',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                rider.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone: ${rider.phone}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildStatusChip(rider.status),
                                      const SizedBox(width: 8),
                                      Text('Orders: ${rider.assignedOrders.length}'),
                                      const SizedBox(width: 8),
                                      if (rider.location != null)
                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showRiderActionsMenu(context, rider),
                              ),
                              onTap: () => _viewRiderDetails(context, rider),
                            ),
                          );
                        },
                      ),
                    ),

                    // Pagination
                    if (adminProvider.totalRiders > _pageSize)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _currentPage > 1
                                  ? () => _onPageChanged(_currentPage - 1)
                                  : null,
                            ),
                            Text(
                              'Page $_currentPage of ${(adminProvider.totalRiders / _pageSize).ceil()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: _currentPage < (adminProvider.totalRiders / _pageSize).ceil()
                                  ? () => _onPageChanged(_currentPage + 1)
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
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'available':
        chipColor = Colors.green;
        statusText = 'Available';
        break;
      case 'busy':
        chipColor = Colors.orange;
        statusText = 'Busy';
        break;
      case 'offline':
        chipColor = Colors.grey;
        statusText = 'Offline';
        break;
      default:
        chipColor = Colors.blue;
        statusText = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
  
  Future<void> _showAddRiderDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Rider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || 
                  emailController.text.isEmpty || 
                  phoneController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final success = await adminProvider.createRider({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'password': passwordController.text,
              });
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Rider created successfully' : 'Failed to create rider')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showRiderActionsMenu(BuildContext context, RiderModel rider) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _viewRiderDetails(context, rider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('View Assigned Orders'),
              onTap: () {
                Navigator.pop(context);
                context.go('/admin-orders', extra: {'riderId': rider.id});
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Rider'),
              onTap: () {
                Navigator.pop(context);
                _showEditRiderDialog(context, rider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(rider.isActive ? 'Deactivate Rider' : 'Activate Rider'),
              onTap: () async {
                Navigator.pop(context);
                final success = await adminProvider.toggleRiderStatus(rider.id, !rider.isActive);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(rider.isActive ? 'Rider deactivated' : 'Rider activated')),
                  );
                  _loadRiders();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewRiderDetails(BuildContext context, RiderModel rider) {
    // We'll navigate to a rider details screen
    context.go('/admin-rider-detail/${rider.id}');
  }
  
  Future<void> _showEditRiderDialog(BuildContext context, RiderModel rider) async {
    final nameController = TextEditingController(text: rider.name);
    final phoneController = TextEditingController(text: rider.phone);
    final emailController = TextEditingController(text: rider.email);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Rider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: rider.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'busy', child: Text('Busy')),
                  DropdownMenuItem(value: 'offline', child: Text('Offline')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final success = await adminProvider.updateRider(rider.id, {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
              });
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Rider updated successfully' : 'Failed to update rider')),
                );
                if (success) {
                  _loadRiders();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
