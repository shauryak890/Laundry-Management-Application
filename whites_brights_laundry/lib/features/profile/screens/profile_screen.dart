import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../../../models/address_model.dart';
import '../../../services/providers/user_provider_mongodb.dart';
import '../../../services/providers/address_provider_mongodb.dart';
import '../../../services/mongodb/auth_service.dart';
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
    
    // Initialize user data from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final addressProvider = Provider.of<AddressProvider>(context, listen: false);
        addressProvider.refreshAddresses();
        // Initialize controllers with current values
        if (userProvider.currentUser != null) {
          _nameController.text = userProvider.currentUser!.name;
          _phoneController.text = userProvider.currentUser!.phone.replaceAll('+91', '');
          _emailController.text = userProvider.currentUser!.email ?? 'user@example.com';
        } else {
          // Fallback to defaults if no user data yet
          _nameController.text = 'Guest User';
          _phoneController.text = '';
          _emailController.text = 'user@example.com';
        }
      }
    });
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.currentUser != null) {
        // Create updated user data
        final updatedUser = UserModel(
          id: userProvider.currentUser!.id,
          name: _nameController.text,
          phone: '+91${_phoneController.text.replaceAll('+91', '')}',
          email: _emailController.text,
          createdAt: userProvider.currentUser!.createdAt,
          updatedAt: DateTime.now(),
          phoneNumber: '+91${_phoneController.text.replaceAll('+91', '')}',
        );
        
        // Update user profile in Firestore
        userProvider.updateUser(updatedUser);
      }
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _showAddAddressDialog() {
    final _formKeyAddress = GlobalKey<FormState>();
    final addressLine1Controller = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Address'),
        content: Form(
          key: _formKeyAddress,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: addressLine1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKeyAddress.currentState!.validate()) {
                final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                addressProvider.createAddress(
                  addressLine1: addressLine1Controller.text,
                  city: cityController.text,
                  state: stateController.text,
                  postalCode: pincodeController.text,
                  isDefault: addressProvider.addresses.isEmpty,
                );
                Navigator.pop(context);
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
            onPressed: () async {
              try {
                Navigator.pop(context);
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing out...')),
                );
                
                // Sign out from Firebase
                await AuthService().logout();
                
                // Navigate to login screen
                if (mounted) {
                  context.go(AppRoutes.login);
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final addressProvider = Provider.of<AddressProvider>(context);
        final user = userProvider.currentUser;

        // Update controllers when user changes
        if (user != null) {
          if (_nameController.text != user.name) {
            _nameController.text = user.name;
          }
          final phone = user.phone.replaceAll('+91', '');
          if (_phoneController.text != phone) {
            _phoneController.text = phone;
          }
          final email = user.email ?? 'user@example.com';
          if (_emailController.text != email) {
            _emailController.text = email;
          }
        } else {
          if (_nameController.text != 'Guest User') {
            _nameController.text = 'Guest User';
          }
          if (_phoneController.text.isNotEmpty) {
            _phoneController.text = '';
          }
          if (_emailController.text != 'user@example.com') {
            _emailController.text = 'user@example.com';
          }
        }

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
                              user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                    if (addressProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (addressProvider.addresses.isEmpty)
                      const Text(
                        'No addresses saved yet. Add your first address.',
                        style: TextStyle(color: AppColors.textLight),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addressProvider.addresses.length,
                        itemBuilder: (context, index) {
                          final address = addressProvider.addresses[index];
                          final isSelected = address.isDefault;
                          return AddressTile(
                            address: address.addressText,
                            isSelected: isSelected,
                            onSelect: () {
                              // Set as default address
                              addressProvider.setDefaultAddress(address.id);
                            },
                            onDelete: () {
                              // Delete address from Firestore
                              addressProvider.deleteAddress(address.id);
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
          floatingActionButton: !_isEditing
              ? FloatingActionButton(
                  onPressed: _showAddAddressDialog,
                  backgroundColor: AppColors.primaryBlue,
                  child: const Icon(Icons.add, color: Colors.white),
                  tooltip: AppStrings.addAddress,
                )
              : null,
        );
      },
    );
  }
}
