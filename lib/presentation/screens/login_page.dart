import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aivio/cubit/auth/auth_cubit.dart';
import 'package:aivio/cubit/auth/auth_state.dart';
import 'package:aivio/presentation/widgets/login/login_header.dart';
import 'package:aivio/presentation/widgets/login/login_email_field.dart';
import 'package:aivio/presentation/widgets/login/login_password_field.dart';
import 'package:aivio/presentation/widgets/login/forgot_password_button.dart';
import 'package:aivio/presentation/widgets/login/login_button.dart';
import 'package:aivio/presentation/widgets/login/login_divider.dart';
import 'package:aivio/presentation/widgets/login/sign_up_section.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                context.read<AuthCubit>().resetPassword(
                  email: emailController.text.trim(),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          } else if (state is PasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Password reset email sent to ${state.email}',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 48),
                      LoginEmailField(
                        controller: _emailController,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 20),
                      LoginPasswordField(
                        controller: _passwordController,
                        obscurePassword: _obscurePassword,
                        enabled: !isLoading,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ForgotPasswordButton(
                        enabled: !isLoading,
                        onPressed: _showResetPasswordDialog,
                      ),
                      const SizedBox(height: 32),
                      LoginButton(
                        isLoading: isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 24),
                      const LoginDivider(),
                      const SizedBox(height: 24),
                      SignUpSection(enabled: !isLoading),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
