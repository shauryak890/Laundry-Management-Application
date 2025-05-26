import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_text_field.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _resendCounter = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCounter = 30;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCounter > 0) {
        setState(() {
          _resendCounter--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOTP(otp);
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = '+91${widget.phoneNumber}'; // Adding country code for India

    await authProvider.verifyPhoneNumber(phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOTP),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions text
                Text(
                  AppStrings.enterOTP,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                // Display phone number
                Text(
                  '+91 ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 32),
                
                // OTP Input
                OtpTextField(controller: _otpController),
                
                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authProvider.error!,
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Resend OTP option
                Center(
                  child: _canResend
                      ? IconButtonWithText(
                          icon: Icons.refresh,
                          text: AppStrings.resendOTP,
                          onTap: _resendOTP,
                        )
                      : Text(
                          'Resend OTP in $_resendCounter seconds',
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                ),
                
                const SizedBox(height: 32),
                
                // Verify Button
                PrimaryButton(
                  text: AppStrings.verifyPhone,
                  onPressed: _verifyOTP,
                  isLoading: authProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
