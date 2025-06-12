import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/screens/order_management_screen.dart';
import 'package:whites_brights_laundry/utils/colors.dart';
import 'package:whites_brights_laundry/utils/order_utils.dart';

class UserDetailScreen extends StatefulWidget {
  static const String routeName = '/admin-user-detail';

  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoadingOrders = false;

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('User: ${user['name']}'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details Card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Avatar and Name
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: GlobalColors.primaryColor,
                            child: Text(
                              user['name'][0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: user['role'] == 'admin' ? Colors.orange : Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        user['role'] ?? 'user',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      // Contact Information
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.email, user['email']),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone, user['phoneNumber'] ?? 'No phone number'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.calendar_today,
                          'Joined on ${_formatDate(user['createdAt'] != null ? DateTime.parse(user['createdAt']) : DateTime.now())}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Addresses Section
              const Text(
                'Addresses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (user['addresses'] != null && (user['addresses'] as List).isNotEmpty)
                ...List.generate(
                  (user['addresses'] as List).length,
                  (index) {
                    final address = user['addresses'][index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: GlobalColors.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address['type'] ?? 'Address ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (address['isDefault'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Default',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(address['addressText'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                const Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No addresses found'),
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // User Orders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View All'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        OrderManagementScreen.routeName,
                        arguments: {'userId': user['_id']},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _isLoadingOrders
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder(
                      future: _fetchUserOrders(user['_id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load orders: ${snapshot.error}',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          );
                        }
                        
                        final orders = Provider.of<AdminProvider>(context).orders;
                        
                        if (orders.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('No orders found for this user'),
                              ),
                            ),
                          );
                        }
                        
                        // Display limited number of orders (most recent)
                        final displayedOrders = orders.take(3).toList();
                        
                        return Column(
                          children: displayedOrders.map((order) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  order.serviceName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order ID: ${order.id.substring(0, 8)}...'),
                                    Text('Status: ${OrderUtils.formatOrderStatus(order.status)}'),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${order.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(order.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Navigate to order detail screen
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
              
              const SizedBox(height: 24),
              
              // Actions Section
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active, color: Colors.blue),
                      title: const Text('Send Notification'),
                      onTap: () {
                        _showSendNotificationDialog(context, user['_id']);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.event_note, color: Colors.purple),
                      title: const Text('View Activity Log'),
                      onTap: () {
                        // Navigate to user activity log
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: GlobalColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _fetchUserOrders(String userId) async {
    setState(() {
      _isLoadingOrders = true;
    });
    
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.fetchOrders(userId: userId, limit: 3);
    } catch (e) {
      // Error will be handled in the FutureBuilder
    } finally {
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  void _showSendNotificationDialog(BuildContext context, String userId) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String notificationType = 'info';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Notification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter notification title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Message',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter notification message',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: notificationType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'info',
                          child: Text('Information'),
                        ),
                        DropdownMenuItem(
                          value: 'success',
                          child: Text('Success'),
                        ),
                        DropdownMenuItem(
                          value: 'warning',
                          child: Text('Warning'),
                        ),
                        DropdownMenuItem(
                          value: 'error',
                          child: Text('Error'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          notificationType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || messageController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                    final result = await adminProvider.sendNotification(
                      userId: userId,
                      title: titleController.text,
                      message: messageController.text,
                      type: notificationType,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? 'Notification sent successfully'
                                : 'Failed to send notification',
                          ),
                          backgroundColor: result ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.primaryColor,
                  ),
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
