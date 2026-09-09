import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../../../core/widgets/afya_error_view.dart';
import '../../../../core/widgets/afya_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form_wrapper.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _otpController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          VerifyEmailSubmitted(
            email: widget.email,
            otp: _otpController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is CreatePinRequired) {
          context.go(RoutePaths.createPin);
        } else if (state is AuthFailure) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        return AuthFormWrapper(
          title: 'Verify your email',
          subtitle: 'Enter the 6-digit code sent to ${widget.email}',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  AfyaErrorView(message: _error!, onRetry: _submit),
                  const SizedBox(height: AppDimensions.space16),
                ],
                AfyaTextField(
                  label: 'Verification code',
                  hint: '123456',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Enter the 6-digit verification code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),
                AfyaButton(
                  text: 'Verify email',
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimensions.space16),
                TextButton(
                  onPressed: () => context.go(RoutePaths.signIn),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
