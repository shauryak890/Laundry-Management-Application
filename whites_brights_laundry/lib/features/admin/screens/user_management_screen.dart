import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/screens/user_detail_screen.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/features/admin/widgets/search_filter_bar.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class UserManagementScreen extends StatefulWidget {
  static const String routeName = '/admin-users';

  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  int _currentPage = 1;
  final int _perPage = 10;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchUsers(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      status: _selectedStatus,
      page: _currentPage,
      limit: _perPage,
    );
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _fetchUsers();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _currentPage = 1;
      _isSearching = false;
    });
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _clearFilters();
                  }
                },
                onSubmitted: (_) => _applyFilters(),
              )
            : const Text('User Management'),
        backgroundColor: GlobalColors.primaryColor,
        actions: [
          // Search button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _applyFilters();
                }
              });
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(selectedIndex: 1),
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoadingUsers) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminProvider.usersError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading users',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final users = adminProvider.users;
            if (users.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Display active filters
                if (_searchController.text.isNotEmpty || _selectedStatus != null)
                  SearchFilterBar(
                    searchTerm: _searchController.text.isEmpty ? null : _searchController.text,
                    filters: _selectedStatus != null ? {'Status': _selectedStatus!} : null,
                    onClear: _clearFilters,
                  ),

                // User list
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: GlobalColors.primaryColor,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email ?? 'No email'),
                              Text(user.phoneNumber.isNotEmpty ? user.phoneNumber : 'No phone'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                UserDetailScreen.routeName,
                                arguments: user,
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              UserDetailScreen.routeName,
                              arguments: user,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Pagination
                if (adminProvider.totalUsers > _perPage)
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
                                  _fetchUsers();
                                }
                              : null,
                        ),
                        Text(
                          'Page $_currentPage of ${(adminProvider.totalUsers / _perPage).ceil()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigate_next),
                          onPressed: _currentPage < (adminProvider.totalUsers / _perPage).ceil()
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                  _fetchUsers();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_searchController.text.isNotEmpty || _selectedStatus != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ]
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _selectedStatus;

        return AlertDialog(
          title: const Text('Filter Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'inactive',
                    child: Text('Inactive'),
                  ),
                ],
                hint: const Text('Select Status'),
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
