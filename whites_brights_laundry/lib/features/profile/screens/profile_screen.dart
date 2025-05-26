import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../../../models/address_model.dart';
import '../../../services/providers/user_provider.dart';
import '../../../services/providers/address_provider.dart';
import '../../../services/firebase/auth_service_firebase.dart';
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
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                
                if (userProvider.currentUser != null) {
                  // Create new address
                  final newAddress = AddressModel(
                    id: '',
                    userId: userProvider.currentUser!.id,
                    addressLine1: _addressController.text,
                    addressText: _addressController.text,
                    isDefault: addressProvider.addresses.isEmpty,
                    addressType: 'Home',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    city: '',
                    state: '',
                    postalCode: '',
                  );
                  
                  // Add address to Firestore
                  addressProvider.addAddress(
                    addressLine1: _addressController.text,
                    city: '',
                    state: '',
                    postalCode: '',
                    addressType: 'Home',
                    isDefault: addressProvider.addresses.isEmpty,
                  );
                }
                
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
            onPressed: () async {
              try {
                Navigator.pop(context);
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing out...')),
                );
                
                // Sign out from Firebase
                await AuthServiceFirebase().signOut();
                
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
    final userProvider = Provider.of<UserProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final user = userProvider.currentUser;
    
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
                          userProvider.currentUser?.name.isNotEmpty ?? false ? userProvider.currentUser!.name[0].toUpperCase() : 'U',
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
                      ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms);
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
