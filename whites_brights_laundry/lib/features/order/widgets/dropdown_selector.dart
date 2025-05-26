import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class DropdownSelector<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final Function(T) onChanged;
  final String Function(T) labelBuilder;

  const DropdownSelector({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedItem,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (T? value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
