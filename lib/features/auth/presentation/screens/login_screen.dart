import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/widgets/custom_button.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_event.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/auth/presentation/screens/display_name_setup_screen.dart';
import 'package:clash_of_minds/features/home/presentation/screens/home_screen.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _handleEmailAuth() {
    dev.log('🔵 _handleEmailAuth called, _isSignUp: $_isSignUp');

    if (_formKey.currentState!.validate()) {
      dev.log('✅ Form validation passed');

      if (_isSignUp) {
        dev.log('📧 Dispatching SignUpWithEmailEvent');
        dev.log('   Email: ${_emailController.text.trim()}');
        dev.log('   Display Name: ${_displayNameController.text.trim()}');
        dev.log('   Password length: ${_passwordController.text.length}');
        context.read<AuthBloc>().add(
              SignUpWithEmailEvent(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                displayName: _displayNameController.text.trim(),
              ),
            );
      } else {
        dev.log('📧 Dispatching SignInWithEmailEvent');
        context.read<AuthBloc>().add(
              SignInWithEmailEvent(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
      }
    } else {
      dev.log('❌ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Check if display name needs to be set
            if (state.user.displayName.contains('@')) {
              context.pushReplacement(const DisplayNameSetupScreen());
            } else {
              context.pushReplacement(const HomeScreen());
            }
          } else if (state is AuthError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icons/app-logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Clash Of Minds',
                    style: context.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Battle of Intellects - Compete in Real-Time',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Sign in with Google button
                  CustomButton(
                    text: 'Sign in with Google',
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context
                                .read<AuthBloc>()
                                .add(SignInWithGoogleEvent());
                          },
                    isLoading: false,
                  ),

                  const SizedBox(height: 24),

                  // OR divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign In / Sign Up toggle
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = false;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: !_isSignUp
                                ? context.colorScheme.primary
                                : Colors.grey,
                            textStyle: TextStyle(
                              fontWeight: !_isSignUp
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = true;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _isSignUp
                                ? context.colorScheme.primary
                                : Colors.grey,
                            textStyle: TextStyle(
                              fontWeight: _isSignUp
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Email/Password Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Display Name (only for sign up)
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            enabled: state is! AuthLoading,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a display name';
                              }
                              if (value.trim().length < 3) {
                                return 'Display name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: state is! AuthLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          enabled: state is! AuthLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        CustomButton(
                          text: _isSignUp ? 'Sign Up' : 'Sign In',
                          onPressed: _handleEmailAuth,
                          isLoading: state is AuthLoading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms and privacy
                  Text(
                    'By signing in, you agree to our Terms of Service and Privacy Policy',
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
