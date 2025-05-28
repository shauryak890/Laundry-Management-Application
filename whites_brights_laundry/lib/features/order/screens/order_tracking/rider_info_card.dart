import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class RiderInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final String? imageUrl;

  const RiderInfoCard({
    Key? key,
    required this.name,
    required this.phone,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Partner',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Profile image or placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                          size: 32,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Rider details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Call button
                IconButton(
                  onPressed: () {
                    // Open phone dialer
                    _showCallDialog(context);
                  },
                  icon: const Icon(
                    Icons.call,
                    color: AppColors.primaryBlue,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Delivery Partner'),
        content: Text('Would you like to call $name at $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, we would launch the phone dialer here
              // using something like url_launcher package
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $name...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
