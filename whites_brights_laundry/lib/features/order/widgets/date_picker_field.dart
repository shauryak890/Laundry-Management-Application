import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class DatePickerField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: value.contains('Select') ? Colors.grey : AppColors.textDark,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
