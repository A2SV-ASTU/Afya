import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String? _firstPin;
  final List<String> _currentDigits = [];
  String? _errorMessage;
  bool _isConfirming = false;

  void _onKeyPress(String digit) {
    if (_currentDigits.length < 4) {
      setState(() {
        _currentDigits.add(digit);
        _errorMessage = null;
      });

      if (_currentDigits.length == 4) {
        final enteredPin = _currentDigits.join();

        if (!_isConfirming) {
          // Move to confirm step
          setState(() {
            _firstPin = enteredPin;
            _currentDigits.clear();
            _isConfirming = true;
          });
        } else {
          // Confirm step
          if (enteredPin == _firstPin) {
            // Match! Submit PIN
            context.read<AuthBloc>().add(SetPinSubmitted(pin: enteredPin));
          } else {
            // Mismatch
            setState(() {
              _errorMessage = 'PINs do not match. Please try again.';
              _currentDigits.clear();
              _firstPin = null;
              _isConfirming = false;
            });
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (_currentDigits.isNotEmpty) {
      setState(() {
        _currentDigits.removeLast();
        _errorMessage = null;
      });
    }
  }

  void _resetFlow() {
    setState(() {
      _firstPin = null;
      _currentDigits.clear();
      _errorMessage = null;
      _isConfirming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pinBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(RoutePaths.dashboard);
          } else if (state is AuthFailure) {
            setState(() {
              _errorMessage = state.message;
              _resetFlow();
            });
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space16,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.space12),

                // Top Logo Header
                Text(
                  'Afya',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.tealPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                const Spacer(flex: 1),

                // Title
                Text(
                  _isConfirming ? 'Confirm your PIN' : 'Create Security PIN',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.tealDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppDimensions.space12),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space24,
                  ),
                  child: Text(
                    _isConfirming
                        ? 'Re-enter your 4-digit PIN to confirm.'
                        : 'Set a 4-digit PIN for fast & secure offline access to your health record.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF5A6E68),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),

                if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFFBA1A1A),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.space32),

                // 4 PIN Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _currentDigits.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? AppColors.tealPrimary
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled
                              ? AppColors.tealPrimary
                              : const Color(0xFFA0B2AC),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                const Spacer(flex: 2),

                // Keypad
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                  ),
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3']),
                      const SizedBox(height: 18),
                      _buildKeypadRow(['4', '5', '6']),
                      const SizedBox(height: 18),
                      _buildKeypadRow(['7', '8', '9']),
                      const SizedBox(height: 18),
                      _buildBottomKeypadRow(),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                if (_isConfirming)
                  TextButton.icon(
                    onPressed: _resetFlow,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Start Over'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.tealPrimary,
                    ),
                  ),

                const SizedBox(height: AppDimensions.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKeyButton(key)).toList(),
    );
  }

  Widget _buildBottomKeypadRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 72, height: 72),
        _buildKeyButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildKeyButton(String label) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onKeyPress(label),
          child: Center(
            child: Text(
              label,
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.tealDark,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _onBackspace,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.tealPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
