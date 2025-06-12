import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:whites_brights_laundry/core/constants.dart';
import 'package:whites_brights_laundry/services/providers/auth_provider.dart';
import 'package:whites_brights_laundry/utils/colors.dart';
import 'package:whites_brights_laundry/widgets/custom_button.dart';
import 'package:whites_brights_laundry/widgets/custom_text_field.dart';

class AdminLoginScreen extends StatefulWidget {
  static const String routeName = '/admin-login';

  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      // Verify if the user has admin role
      if (result['success'] && authProvider.user != null) {
        final user = authProvider.user!;
        
        if (user.role == 'admin') {
          if (!mounted) return;
          context.go(AppRoutes.adminDashboard);
        } else {
          throw Exception('You do not have admin privileges');
        }
      } else {
        throw Exception(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: GlobalColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Error message if any
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    hint: 'Email',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Login button
                  CustomButton(
                    text: _isLoading ? 'Logging in...' : 'Login',
                    onPressed: _isLoading ? () {} : _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  
                  // Back to user app
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: const Text('Back to User App'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
