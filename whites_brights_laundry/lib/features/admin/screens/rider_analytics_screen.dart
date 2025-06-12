import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/models/rider_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class RiderAnalyticsScreen extends StatefulWidget {
  static const String routeName = '/admin-rider-analytics';
  
  const RiderAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<RiderAnalyticsScreen> createState() => _RiderAnalyticsScreenState();
}

class _RiderAnalyticsScreenState extends State<RiderAnalyticsScreen> {
  bool _isLoading = true;
  String _selectedTimeRange = 'week'; // 'day', 'week', 'month'
  String? _selectedRiderId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.fetchRiders();
      
      // If we have riders, select the first one by default
      if (adminProvider.riders.isNotEmpty && _selectedRiderId == null) {
        _selectedRiderId = adminProvider.riders.first.id;
      }
      
      // Here we would fetch analytics data for the selected rider and time range
      // This would be implemented in the AdminProvider
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Analytics'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      drawer: const AdminDrawer(selectedIndex: 7), // Adjust index as needed
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                final riders = adminProvider.riders;
                
                if (riders.isEmpty) {
                  return const Center(
                    child: Text('No riders available'),
                  );
                }
                
                // Find the selected rider
                final selectedRider = riders.firstWhere(
                  (rider) => rider.id == _selectedRiderId,
                  orElse: () => riders.first,
                );
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rider selector
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Rider',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedRiderId,
                        items: riders.map((rider) {
                          return DropdownMenuItem<String>(
                            value: rider.id,
                            child: Text(rider.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRiderId = value;
                          });
                          _loadData();
                        },
                      ),
                    ),
                    
                    // Time range selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Text('Time Range: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Day'),
                            selected: _selectedTimeRange == 'day',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeRange = 'day';
                                });
                                _loadData();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Week'),
                            selected: _selectedTimeRange == 'week',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeRange = 'week';
                                });
                                _loadData();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Month'),
                            selected: _selectedTimeRange == 'month',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeRange = 'month';
                                });
                                _loadData();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Rider performance metrics
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rider info card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: GlobalColors.primaryColor,
                                          backgroundImage: selectedRider.profileImageUrl != null
                                              ? NetworkImage(selectedRider.profileImageUrl!)
                                              : null,
                                          child: selectedRider.profileImageUrl == null
                                              ? Text(
                                                  selectedRider.name.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 24,
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
                                                selectedRider.name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text('Status: ${selectedRider.status}'),
                                              Text('Rating: ${selectedRider.rating}/5.0'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Performance metrics
                            const Text(
                              'Performance Metrics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Metrics grid
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              children: [
                                _buildMetricCard(
                                  'Completed Orders',
                                  selectedRider.completedOrders.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                                _buildMetricCard(
                                  'On-Time Delivery',
                                  '${(selectedRider.rating * 20).toInt()}%',
                                  Icons.timer,
                                  Colors.blue,
                                ),
                                _buildMetricCard(
                                  'Average Delivery Time',
                                  '${(30 + (5 - selectedRider.rating) * 5).toInt()} min',
                                  Icons.speed,
                                  Colors.orange,
                                ),
                                _buildMetricCard(
                                  'Customer Satisfaction',
                                  '${(selectedRider.rating * 20).toInt()}%',
                                  Icons.thumb_up,
                                  Colors.purple,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Recent activity
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Placeholder for recent activity
                            Card(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 5,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  // This would be replaced with actual activity data
                                  return ListTile(
                                    leading: Icon(
                                      index % 2 == 0 ? Icons.delivery_dining : Icons.shopping_bag,
                                      color: GlobalColors.primaryColor,
                                    ),
                                    title: Text('Order #${10000 + index}'),
                                    subtitle: Text(
                                      'Delivered on ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().subtract(Duration(days: index)).month}',
                                    ),
                                    trailing: Text(
                                      index % 2 == 0 ? 'On Time' : 'Delayed',
                                      style: TextStyle(
                                        color: index % 2 == 0 ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
  
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
