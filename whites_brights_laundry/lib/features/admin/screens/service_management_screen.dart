import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/features/admin/widgets/admin_drawer.dart';
import 'package:whites_brights_laundry/models/service_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';

class ServiceManagementScreen extends StatefulWidget {
  static const String routeName = '/admin-services';

  const ServiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      drawer: const AdminDrawer(selectedIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditServiceDialog(context);
        },
        backgroundColor: GlobalColors.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoadingServices) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminProvider.servicesError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading services',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchServices,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final services = adminProvider.services;
            if (services.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final color = service.color;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service name and price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(service.color.value),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  label: Text(service.isAvailable ? 'Available' : 'Unavailable'),
                                  backgroundColor: service.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                                  labelStyle: TextStyle(
                                    color: service.isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: GlobalColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '₹${service.price.toString()} / ${service.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: GlobalColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (service.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            service.description,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Edit button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                              onPressed: () => _showAddEditServiceDialog(context, service),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GlobalColors.primaryColor,
                                side: BorderSide(color: GlobalColors.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Delete'),
                              onPressed: () => _showDeleteConfirmationDialog(context, service),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            Icons.cleaning_services_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GlobalColors.primaryColor,
            ),
            onPressed: () {
              _showAddEditServiceDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditServiceDialog(BuildContext context, [ServiceModel? service]) {
    final isEditing = service != null;
    
    final nameController = TextEditingController(text: isEditing ? service.name : '');
    final priceController = TextEditingController(
      text: isEditing ? service.price.toString() : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? service.description : '',
    );
    
    String selectedUnit = isEditing ? service.unit : 'kg';
    Color selectedColor = isEditing ? Color(service.color.value) : const Color(0xFF2196F3);
    bool isAvailable = isEditing ? service.isAvailable : true;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${isEditing ? 'Edit' : 'Add'} Service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    const Text(
                      'Service Name *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter service name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price field and Unit dropdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Enter price',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unit *',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'kg',
                                    child: Text('kg'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'piece',
                                    child: Text('piece'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'item',
                                    child: Text('item'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedUnit = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Color selection
                    const Text(
                      'Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _colorOption('#2196F3', 'Blue', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _colorOption('#4CAF50', 'Green', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _colorOption('#F44336', 'Red', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _colorOption('#FF9800', 'Orange', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _colorOption('#9C27B0', 'Purple', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _colorOption('#607D8B', 'Grey', selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Availability toggle
                    Row(
                      children: [
                        const Text(
                          'Available',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          },
                          activeColor: GlobalColors.primaryColor,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description field
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter service description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
                    // Validate inputs
                    if (nameController.text.isEmpty || priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Prepare service data
                    final serviceData = {
                      'name': nameController.text,
                      'price': double.tryParse(priceController.text) ?? 0,
                      'unit': selectedUnit,
                      'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                      'description': descriptionController.text,
                      'isAvailable': isAvailable,
                      'estimatedTimeHours': isEditing ? service.estimatedTimeHours : 24,
                      'iconUrl': isEditing ? service.iconUrl : '',
                    };
                    
                    Navigator.pop(context);
                    
                    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                    bool result;
                    
                    if (isEditing) {
                      result = await adminProvider.updateService(service.id, serviceData);
                    } else {
                      result = await adminProvider.createService(serviceData);
                    }
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? '${isEditing ? 'Updated' : 'Created'} service successfully'
                                : 'Failed to ${isEditing ? 'update' : 'create'} service',
                          ),
                          backgroundColor: result ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.primaryColor,
                  ),
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _colorOption(String colorHex, String colorName, Color selectedColor, Function(Color) onSelect) {
    final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
    final isSelected = color.value == selectedColor.value;
    
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              colorName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete the service "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final result = await adminProvider.deleteService(service.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result ? 'Service deleted successfully' : 'Failed to delete service',
                    ),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
