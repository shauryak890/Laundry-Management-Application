import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/models/admin_log_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class AdminLogsScreen extends StatefulWidget {
  static const String routeName = '/admin-logs';

  const AdminLogsScreen({Key? key}) : super(key: key);

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  int _currentPage = 1;
  final int _perPage = 20;
  String? _selectedAction;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    // Use the fetchAdminLogs method without parameters as they're not supported in the current implementation
    await adminProvider.fetchAdminLogs();
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _fetchLogs();
  }

  void _clearFilters() {
    setState(() {
      _selectedAction = null;
      _currentPage = 1;
    });
    _fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Activity Logs'),
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
      drawer: const AdminDrawer(selectedIndex: 5),
      body: RefreshIndicator(
        onRefresh: _fetchLogs,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoadingLogs) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminProvider.logsError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading logs',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchLogs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final logs = adminProvider.adminLogs;
            if (logs.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Display active filters
                if (_selectedAction != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Action: $_selectedAction',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _clearFilters,
                        ),
                      ],
                    ),
                  ),

                // Logs list
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return _buildLogCard(logs[index]);
                    },
                  ),
                ),

                // Pagination
                if (adminProvider.totalLogs > _perPage)
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
                                  _fetchLogs();
                                }
                              : null,
                        ),
                        Text(
                          'Page $_currentPage of ${(adminProvider.totalLogs / _perPage).ceil()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigate_next),
                          onPressed:
                              _currentPage < (adminProvider.totalLogs / _perPage).ceil()
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                      _fetchLogs();
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

  Widget _buildLogCard(AdminLogModel log) {
    // Define icon and color based on action type
    IconData actionIcon;
    Color actionColor;

    switch (log.action) {
      case 'login':
        actionIcon = Icons.login;
        actionColor = Colors.blue;
        break;
      case 'logout':
        actionIcon = Icons.logout;
        actionColor = Colors.purple;
        break;
      case 'create':
        actionIcon = Icons.add_circle_outline;
        actionColor = Colors.green;
        break;
      case 'update':
        actionIcon = Icons.edit;
        actionColor = Colors.orange;
        break;
      case 'delete':
        actionIcon = Icons.delete_outline;
        actionColor = Colors.red;
        break;
      case 'view':
        actionIcon = Icons.visibility;
        actionColor = Colors.teal;
        break;
      default:
        actionIcon = Icons.info_outline;
        actionColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action and timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(actionIcon, color: actionColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      log.actionDisplay,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDateTime(log.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Log details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                log.detailsDisplay,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Admin info and user agent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      log.adminName ?? log.adminId.substring(0, 8),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.desktop_windows, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _truncateUserAgent(log.userAgent),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncateUserAgent(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) {
      return 'Unknown';
    }
    
    // Extract browser and device info
    final parts = userAgent.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}...';
    }
    return userAgent.length > 20 ? '${userAgent.substring(0, 20)}...' : userAgent;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No admin logs found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedAction != null) ...[
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempAction = _selectedAction;

        return AlertDialog(
          title: const Text('Filter Activity Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Action Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: tempAction,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Actions'),
                  ),
                  ...['login', 'logout', 'create', 'update', 'delete', 'view']
                      .map((action) => DropdownMenuItem<String?>(
                            value: action,
                            child: Text(action[0].toUpperCase() + action.substring(1)),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  tempAction = value;
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
                  _selectedAction = tempAction;
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
