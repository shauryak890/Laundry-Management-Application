import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;
  final double height;
  final double fontSize;
  final Widget? icon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 50,
    this.fontSize = 16,
    this.icon,
  }) : assert(onPressed != null || onTap != null, 'Either onPressed or onTap must be provided'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isOutlined 
              ? backgroundColor ?? AppColors.primaryColor 
              : textColor ?? Colors.white,
          backgroundColor: isOutlined 
              ? Colors.transparent 
              : backgroundColor ?? AppColors.primaryColor,
          side: isOutlined
              ? BorderSide(color: backgroundColor ?? AppColors.primaryColor)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: isLoading ? null : (onPressed ?? onTap),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
