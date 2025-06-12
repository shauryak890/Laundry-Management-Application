import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whites_brights_laundry/features/admin/providers/admin_provider.dart';
import 'package:whites_brights_laundry/models/order_model.dart';
import 'package:whites_brights_laundry/utils/colors.dart';
import 'package:whites_brights_laundry/utils/order_utils.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = '/admin-order-detail';

  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        backgroundColor: GlobalColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(order),
              
              const SizedBox(height: 24),
              
              // Order Details Card
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
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildDetailRow('Order ID', order.id),
                      _buildDetailRow('Service', order.serviceName),
                      _buildDetailRow('Quantity', '${order.quantity} ${order.serviceUnit}'),
                      _buildDetailRow('Price per Unit', '₹${order.servicePrice.toStringAsFixed(2)}'),
                      _buildDetailRow('Total Price', '₹${order.totalPrice.toStringAsFixed(2)}'),
                      _buildDetailRow('Pickup Date', _formatDate(order.pickupDate)),
                      _buildDetailRow('Time Slot', order.timeSlot),
                      _buildDetailRow('Delivery Date', _formatDate(order.deliveryDate)),
                      _buildDetailRow('Created At', _formatDateTime(order.createdAt)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Address Card
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
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: GlobalColors.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(order.addressText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Actions Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _showUpdateStatusBottomSheet(context, order);
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Generate Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _generateInvoice(order.id);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (order.status != 'cancelled' && order.status != 'delivered')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _showCancelConfirmationDialog(context, order);
                      },
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    Color statusColor;
    IconData statusIcon;
    
    switch (order.status) {
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case 'pickedUp':
        statusColor = Colors.orange;
        statusIcon = Icons.directions_car;
        break;
      case 'inProcess':
        statusColor = Colors.purple;
        statusIcon = Icons.local_laundry_service;
        break;
      case 'outForDelivery':
        statusColor = Colors.amber;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Text(
            OrderUtils.formatOrderStatus(order.status),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Status formatting now handled by OrderUtils class

  void _showUpdateStatusBottomSheet(BuildContext context, OrderModel order) {
    final allStatuses = [
      {'value': 'scheduled', 'label': 'Scheduled', 'icon': Icons.schedule, 'color': Colors.blue},
      {'value': 'pickedUp', 'label': 'Picked Up', 'icon': Icons.directions_car, 'color': Colors.orange},
      {'value': 'inProcess', 'label': 'In Process', 'icon': Icons.local_laundry_service, 'color': Colors.purple},
      {'value': 'outForDelivery', 'label': 'Out For Delivery', 'icon': Icons.local_shipping, 'color': Colors.amber},
      {'value': 'delivered', 'label': 'Delivered', 'icon': Icons.check_circle, 'color': Colors.green},
      {'value': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel, 'color': Colors.red},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Order Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Current Status:'),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: OrderUtils.getStatusColor(order).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: OrderUtils.getStatusColor(order)),
                ),
                child: Text(
                  OrderUtils.formatOrderStatus(order.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: OrderUtils.getStatusColor(order),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select New Status:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: allStatuses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final status = allStatuses[index];
                    final isCurrentStatus = status['value'] == order.status;
                    
                    return ListTile(
                      leading: Icon(
                        status['icon'] as IconData,
                        color: status['color'] as Color,
                      ),
                      title: Text(status['label'] as String),
                      enabled: !isCurrentStatus,
                      selected: isCurrentStatus,
                      trailing: isCurrentStatus
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: isCurrentStatus
                          ? null
                          : () async {
                              Navigator.pop(context);
                              
                              setState(() {
                                _isLoading = true;
                              });
                              
                              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                              final result = await adminProvider.updateOrderStatus(
                                order.id,
                                status['value'] as String,
                              );
                              
                              setState(() {
                                _isLoading = false;
                              });
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result
                                          ? 'Order status updated successfully'
                                          : 'Failed to update order status',
                                    ),
                                    backgroundColor: result ? Colors.green : Colors.red,
                                  ),
                                );
                                
                                if (result) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                setState(() {
                  _isLoading = true;
                });
                
                final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                final result = await adminProvider.updateOrderStatus(order.id, 'cancelled');
                
                setState(() {
                  _isLoading = false;
                });
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result
                            ? 'Order cancelled successfully'
                            : 'Failed to cancel order',
                      ),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                  
                  if (result) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text(
                'Yes, Cancel Order',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateInvoice(String orderId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final invoiceData = await adminProvider.generateInvoice(orderId);
      
      if (context.mounted) {
        if (invoiceData != null) {
          // In a real app, here we would handle opening a PDF viewer
          // or downloading the PDF file
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice generated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate invoice'),
              backgroundColor: Colors.red,
            ),
          );
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
        _isLoading = false;
      });
    }
  }
}
