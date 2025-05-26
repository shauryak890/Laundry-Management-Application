import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../services/providers/order_provider.dart';
import '../../../widgets/buttons.dart';
import '../widgets/dropdown_selector.dart';
import '../widgets/date_picker_field.dart';

class ScheduleScreen extends StatefulWidget {
  final int serviceId;

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
  final List<String> _addressList = [];
  String? _selectedAddress;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // Ensure we have the correct service selected
    orderProvider.setSelectedService(widget.serviceId);
    
    // Initialize with first address if available
    _addressList.addAll(orderProvider.savedAddresses);
    if (_addressList.isNotEmpty) {
      _selectedAddress = _addressList[0];
      orderProvider.setSelectedAddress(_selectedAddress!);
    }
    
    // Initialize with default time slot
    _selectedTimeSlot = orderProvider.timeSlot;
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
    Provider.of<OrderProvider>(context, listen: false).setItemCount(_quantity);
  }

  void _decreaseQuantity() {
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
    
    // Ensure minimum delivery date is day after pickup
    final DateTime minDate = orderProvider.pickupDate?.add(const Duration(days: 1)) ?? 
        DateTime.now().add(const Duration(days: 1));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
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
      orderProvider.setDeliveryDate(picked);
    }
  }

  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
    });
    Provider.of<OrderProvider>(context, listen: false).setTimeSlot(slot);
  }

  void _onAddressSelected(String address) {
    setState(() {
      _selectedAddress = address;
    });
    Provider.of<OrderProvider>(context, listen: false).setSelectedAddress(address);
  }

  void _confirmSchedule() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // Validate that all required fields are filled
    if (orderProvider.pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup date')),
      );
      return;
    }
    
    if (orderProvider.deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery date')),
      );
      return;
    }
    
    if (orderProvider.selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }
    
    // Navigate to order summary
    context.push(AppRoutes.orderSummary);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final service = orderProvider.selectedService;
    
    if (service == null) {
      // Service not found, go back to home
      Future.microtask(() => context.go(AppRoutes.home));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.schedule),
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
                          color: service['color'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_laundry_service,
                          color: AppColors.primaryBlue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${service['price'].toStringAsFixed(2)} / ${service['unit']}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Quantity selector
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
              DatePickerField(
                value: orderProvider.pickupDate == null
                    ? 'Select Pickup Date'
                    : orderProvider.formattedPickupDate,
                onTap: () => _selectPickupDate(context),
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
              DatePickerField(
                value: orderProvider.deliveryDate == null
                    ? 'Select Delivery Date'
                    : orderProvider.formattedDeliveryDate,
                onTap: () => _selectDeliveryDate(context),
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
                  items: _addressList,
                  selectedItem: _selectedAddress ?? _addressList[0],
                  onChanged: _onAddressSelected,
                  labelBuilder: (item) => item,
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
                            '${service['name']} x $_quantity',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${(service['price'] * _quantity).toStringAsFixed(2)}',
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
                            '\$${orderProvider.totalPrice.toStringAsFixed(2)}',
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
