import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_wrapper.dart';
import '../widgets/pin_login_view.dart';

class SignInScreen extends StatefulWidget {
  final bool initialPinMode;

  const SignInScreen({
    super.key,
    this.initialPinMode = false,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _isPinMode;
  String? _pinError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _isPinMode = widget.initialPinMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _passwordError = null;
      });
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _handlePinSubmitted(String pin) {
    setState(() {
      _pinError = null;
    });
    context.read<AuthBloc>().add(PinLoginSubmitted(pin: pin));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(RoutePaths.dashboard);
        } else if (state is PinRequired) {
          setState(() {
            _isPinMode = true;
            _pinError = null;
          });
        } else if (state is AuthFailure) {
          setState(() {
            if (_isPinMode) {
              _pinError = state.message;
              _passwordError = null;
            } else {
              _passwordError = state.message;
              _pinError = null;
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        if (_isPinMode) {
          return Scaffold(
            body: PinLoginView(
              isLoading: isLoading,
              errorMessage: _pinError,
              onSubmitPin: _handlePinSubmitted,
              onSwitchToPasswordLogin: () {
                setState(() {
                  _isPinMode = false;
                  _pinError = null;
                });
              },
            ),
          );
        }

        return AuthFormWrapper(
          title: 'Welcome Back',
          subtitle: 'Sign in to access your medical records and schedules',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_passwordError != null) ...[
                  AfyaErrorView(
                    message: _passwordError!,
                    onRetry: () => _submitLogin(),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],
                AfyaTextField(
                  label: 'Email Address',
                  hint: 'user@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email address is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),
                AfyaTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),
                AfyaButton(
                  text: 'Sign In',
                  isLoading: isLoading,
                  onPressed: _submitLogin,
                ),
                const SizedBox(height: AppDimensions.space16),
                AfyaButton(
                  text: 'Unlock with PIN',
                  isSecondary: true,
                  onPressed: () {
                    setState(() {
                      _isPinMode = true;
                      _passwordError = null;
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RoutePaths.signUp),
                      child: Text(
                        'Register',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.tealPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
