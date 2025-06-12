import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../core/map_utils.dart';
import '../../../models/service_model.dart';
import '../../../services/providers/order_provider_mongodb.dart';
import '../../../services/providers/address_provider_mongodb.dart';
import '../../../models/address_model.dart';
import '../../../services/providers/service_provider.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../widgets/dropdown_selector.dart';
import '../widgets/date_picker_field.dart';

Color? parseColor(dynamic colorValue) {
  if (colorValue is int) return Color(colorValue);
  if (colorValue is String) {
    String hex = colorValue.replaceAll('#', '').replaceAll('0x', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.tryParse('0x$hex') ?? 0xFF000000);
  }
  return null;
}

class ScheduleScreen extends StatefulWidget {
  final String serviceId;

  const ScheduleScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening'];
  String _selectedTimeSlot = 'Morning';
  List<AddressModel> _addressList = [];
  String? _selectedAddressId;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    
    // Schedule the service selection after the frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      // Ensure we have the correct service selected
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final service = serviceProvider.services.firstWhere(
        (s) => s.id == widget.serviceId,
        orElse: () => ServiceModel(
          id: widget.serviceId,
          name: 'Default Service',
          description: '',
          price: 199.0,
          unit: 'kg',
          iconUrl: '',
          color: Colors.blue,
          isAvailable: true,
          estimatedTimeHours: 24,
        ),
      );
      orderProvider.setSelectedService(service.id);
      
      // Fetch addresses from AddressProvider
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      _addressList = List<AddressModel>.from(addressProvider.addresses);
      if (_addressList.isNotEmpty) {
        setState(() {
          _selectedAddressId = _addressList[0].id;
        });
        orderProvider.setSelectedAddress(_selectedAddressId!);
      }
      
      // Initialize with default time slot
      setState(() {
        _selectedTimeSlot = orderProvider.timeSlot;
      });
    });
  }

  void _increaseQuantity() {
    if (!mounted) return;
    setState(() {
      _quantity++;
    });
    Provider.of<OrderProvider>(context, listen: false).setItemCount(_quantity);
  }

  void _decreaseQuantity() {
    if (!mounted) return;
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      Provider.of<OrderProvider>(context, listen: false).setItemCount(_quantity);
    }
  }

  Future<void> _selectPickupDate(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final DateTime initialDate = orderProvider.pickupDate ?? DateTime.now().add(const Duration(days: 1));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      orderProvider.setPickupDate(picked);
    }
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final DateTime initialDate = orderProvider.deliveryDate ?? 
      (orderProvider.pickupDate?.add(const Duration(days: 1)) ?? 
      DateTime.now().add(const Duration(days: 2)));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: orderProvider.pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      orderProvider.setDeliveryDate(picked);
    }
  }

  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
    });
    Provider.of<OrderProvider>(context, listen: false).setTimeSlot(slot);
  }

  void _onAddressSelected(String? addressId) {
    if (addressId != null) {
      setState(() {
        _selectedAddressId = addressId;
      });
      Provider.of<OrderProvider>(context, listen: false).setSelectedAddress(addressId);
    }
  }

  void _confirmSchedule() {
    // Navigate to order summary
    context.push(AppRoutes.orderSummary);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final serviceId = orderProvider.selectedService;
    
    // Get the full service details from ServiceProvider
    final service = serviceProvider.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => ServiceModel(
        id: serviceId ?? '1',
        name: 'Wash & Fold',
        description: '',
        price: 199.0,
        unit: 'kg',
        iconUrl: '',
        color: Colors.blue,
        isAvailable: true,
        estimatedTimeHours: 24,
      ),
    );
    
    // Extract service fields safely
    String serviceName = service.name;
    String serviceUnit = service.unit;
    double servicePrice = service.price;
    Color serviceColor = service.color;
    
    // Ensure we have a default price if none is available
    if (servicePrice <= 0) {
      servicePrice = 199.0; // Updated default price
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.schedule),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Schedule tab
        onItemSelected: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0: // Home
              context.go(AppRoutes.home);
              break;
            case 1: // Orders
              context.push('/order-history');
              break;
            case 2: // Schedule - already here
              break;
            case 3: // Profile
              context.push(AppRoutes.profile);
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Service Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: serviceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_laundry_service,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${servicePrice.toStringAsFixed(0)} / $serviceUnit',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _decreaseQuantity,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primaryBlue,
                          ),
                          Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: _increaseQuantity,
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Pickup Date
              Text(
                'Pickup Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectPickupDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderProvider.formattedPickupDate.isEmpty
                          ? 'Select Pickup Date'
                          : orderProvider.formattedPickupDate,
                        style: TextStyle(
                          color: orderProvider.formattedPickupDate.isEmpty
                            ? Colors.grey[600]
                            : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Delivery Date
              Text(
                'Delivery Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDeliveryDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderProvider.formattedDeliveryDate.isEmpty
                          ? 'Select Delivery Date'
                          : orderProvider.formattedDeliveryDate,
                        style: TextStyle(
                          color: orderProvider.formattedDeliveryDate.isEmpty
                            ? Colors.grey[600]
                            : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Time Slot
              Text(
                'Preferred Time Slot',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownSelector<String>(
                items: _timeSlots,
                selectedItem: _selectedTimeSlot,
                onChanged: _onTimeSlotSelected,
                labelBuilder: (item) => item,
              ),
              const SizedBox(height: 24),
              
              // Address
              Text(
                'Delivery Address',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_addressList.isEmpty)
                const Text(
                  'No addresses found. Please add an address in your profile.',
                  style: TextStyle(color: AppColors.textLight),
                )
              else
                DropdownSelector<String>(
                  items: _addressList.map((a) => a.id as String).toList(),
                  selectedItem: _selectedAddressId ?? _addressList[0].id,
                  onChanged: _onAddressSelected,
                  labelBuilder: (id) {
                    final address = _addressList.firstWhere(
                      (a) => a.id == id, 
                      orElse: () => AddressModel(
                        id: id, 
                        userId: '', 
                        addressLine1: '', 
                        city: '', 
                        state: '', 
                        pincode: '', 
                        isDefault: false, 
                        label: 'home'
                      )
                    );
                    return '${address.addressLine1}, ${address.city} (${address.pincode})';
                  },
                ),
              const SizedBox(height: 32),
              
              // Price Summary
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$serviceName x $_quantity',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '₹${(servicePrice * _quantity).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${(servicePrice * _quantity).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Confirm Button
              PrimaryButton(
                text: AppStrings.confirmSchedule,
                onPressed: _confirmSchedule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}