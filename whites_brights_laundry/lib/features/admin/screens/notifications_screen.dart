import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/admin-notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSendingNotification = false;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  bool _isBroadcast = true;
  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      drawer: const AdminDrawer(selectedIndex: 4),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Send Notification Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send New Notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Notification Target
                      const Text(
                        'Send To:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('All Users'),
                              value: true,
                              groupValue: _isBroadcast,
                              onChanged: (value) {
                                setState(() {
                                  _isBroadcast = value!;
                                  _selectedUserId = null;
                                  _selectedUserName = null;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Specific User'),
                              value: false,
                              groupValue: _isBroadcast,
                              onChanged: (value) {
                                setState(() {
                                  _isBroadcast = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                      
                      // User Selection (if not broadcast)
                      if (!_isBroadcast) 
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: OutlinedButton(
                            onPressed: () {
                              _selectUser(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: GlobalColors.primaryColor,
                            ),
                            child: Text(
                              _selectedUserId != null 
                                ? 'Selected: $_selectedUserName' 
                                : 'Select User',
                            ),
                          ),
                        ),
                      
                      // Notification Type
                      const Text(
                        'Notification Type:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
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
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Title Field
                      const Text(
                        'Title:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter notification title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Message Field
                      const Text(
                        'Message:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Enter notification message',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      
                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSendingNotification ? null : _sendNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSendingNotification
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Send Notification'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Notifications Section
              const Text(
                'Recent Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Notification List
              Expanded(
                child: Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.isLoadingNotifications) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (adminProvider.notificationsError != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading notifications',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchNotifications,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final notifications = adminProvider.notifications;
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final DateTime createdAt = DateTime.parse(notification['createdAt']);
    final bool isBroadcast = notification['type'] == 'broadcast';
    
    // Determine notification icon and color
    IconData iconData;
    Color iconColor;
    
    switch (notification['type']) {
      case 'info':
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      case 'success':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'warning':
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        break;
      case 'error':
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(notification['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isBroadcast ? Icons.public : Icons.person,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  isBroadcast ? 'Broadcast' : 'To User',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Show full notification details
          _showNotificationDetails(notification);
        },
      ),
    );
  }
  
  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(notification['message']),
                const SizedBox(height: 16),
                const Divider(),
                Text(
                  'Sent: ${_formatDateTime(DateTime.parse(notification['createdAt']))}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Type: ${notification['type'] == 'broadcast' ? 'Broadcast to all users' : 'Sent to specific user'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (notification['user'] != null)
                  Text(
                    'Recipient: ${notification['user']['name'] ?? notification['user']['email']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _sendNotification() async {
    // Validate inputs
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_isBroadcast && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSendingNotification = true;
    });
    
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      bool result;
      
      if (_isBroadcast) {
        result = await adminProvider.sendBroadcastNotification(
          title: _titleController.text,
          message: _messageController.text,
          type: _selectedType,
        );
      } else {
        result = await adminProvider.sendUserNotification(
          userId: _selectedUserId!,
          title: _titleController.text,
          message: _messageController.text,
          type: _selectedType,
        );
      }
      
      if (context.mounted) {
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
        
        if (result) {
          _titleController.clear();
          _messageController.clear();
          _fetchNotifications();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSendingNotification = false;
      });
    }
  }
  
  void _selectUser(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchUsers();
    final users = adminProvider.users;
    
    if (context.mounted && users.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          String searchQuery = '';
          List<dynamic> filteredUsers = List.from(users);
          
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select User'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search field
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by name or email',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                            filteredUsers = users.where((user) {
                              final name = user.name.toLowerCase();
                              final email = (user.email ?? '').toLowerCase();
                              return name.contains(searchQuery) || email.contains(searchQuery);
                            }).toList();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // User list
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(user['name'] ?? 'No Name'),
                              subtitle: Text(user['email']),
                              onTap: () {
                                setState(() {
                                  _selectedUserId = user['_id'];
                                  _selectedUserName = user['name'] ?? user['email'];
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
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
                ],
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load users'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
