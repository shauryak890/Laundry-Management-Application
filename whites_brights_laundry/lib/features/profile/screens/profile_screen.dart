import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../services/providers/order_provider.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_text_field.dart';
import '../widgets/address_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize controllers with current values
    _nameController.text = authProvider.userName;
    _phoneController.text = authProvider.userPhone.replaceAll('+91', '');
    
    // Email is not stored in the provider in this demo, so we use a placeholder
    _emailController.text = 'user@example.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Update user profile
      authProvider.updateUserProfile(
        name: _nameController.text,
      );
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address'),
        content: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Enter your full address',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_addressController.text.isNotEmpty) {
                Provider.of<OrderProvider>(context, listen: false)
                    .addAddress(_addressController.text);
                Navigator.pop(context);
                _addressController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryBlue,
                        child: Text(
                          authProvider.userName.isNotEmpty ? authProvider.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Profile Information
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name Field
                CustomTextField(
                  hint: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  readOnly: !_isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  hint: 'Email Address',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: !_isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                PhoneTextField(
                  controller: _phoneController,
                ),
                
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Addresses Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.manageAddresses,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddAddressDialog,
                      tooltip: AppStrings.addAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Address List
                if (orderProvider.savedAddresses.isEmpty)
                  const Text(
                    'No addresses saved yet. Add your first address.',
                    style: TextStyle(color: AppColors.textLight),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderProvider.savedAddresses.length,
                    itemBuilder: (context, index) {
                      final address = orderProvider.savedAddresses[index];
                      final isSelected = address == orderProvider.selectedAddress;
                      
                      return AddressTile(
                        address: address,
                        isSelected: isSelected,
                        onSelect: () {
                          orderProvider.setSelectedAddress(address);
                        },
                        onDelete: () {
                          orderProvider.removeAddress(address);
                        },
                      );
                    },
                  ),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                SecondaryButton(
                  text: 'Sign Out',
                  onPressed: _signOut,
                  icon: Icons.logout,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !_isEditing ? FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}
