import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aivio/cubit/auth/auth_cubit.dart';
import 'package:aivio/cubit/auth/auth_state.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_app_bar.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_header.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_name_field.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_email_field.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_password_field.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_confirm_password_field.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_button.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_divider.dart';
import 'package:aivio/presentation/widgets/sign_up/sign_up_login_redirect.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );
    }
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
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                SignUpAppBar(
                  onBack: () => Navigator.of(context).pop(),
                  isLoading: isLoading,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SignUpHeader(),
                          const SizedBox(height: 40),
                          SignUpNameField(
                            controller: _nameController,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),
                          SignUpEmailField(
                            controller: _emailController,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),
                          SignUpPasswordField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !isLoading,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          SignUpConfirmPasswordField(
                            controller: _confirmPasswordController,
                            password: _passwordController.text,
                            obscureText: _obscureConfirmPassword,
                            enabled: !isLoading,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 32),
                          SignUpButton(
                            onPressed: _handleSignUp,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 24),
                          const SignUpDivider(),
                          const SizedBox(height: 24),
                          SignUpLoginRedirect(
                            onLoginTap: () => Navigator.of(context).pop(),
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
