import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class PinLoginView extends StatefulWidget {
  final Function(String pin) onSubmitPin;
  final VoidCallback onSwitchToPasswordLogin;
  final String? errorMessage;
  final bool isLoading;

  const PinLoginView({
    super.key,
    required this.onSubmitPin,
    required this.onSwitchToPasswordLogin,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  final List<String> _pinDigits = [];

  @override
  void didUpdateWidget(covariant PinLoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _pinDigits.clear();
      });
    }
  }

  void _onKeyPress(String digit) {
    if (widget.isLoading) return;
    if (_pinDigits.length < 4) {
      setState(() {
        _pinDigits.add(digit);
      });
      if (_pinDigits.length == 4) {
        final pin = _pinDigits.join();
        widget.onSubmitPin(pin);
      }
    }
  }

  void _onBackspace() {
    if (widget.isLoading) return;
    if (_pinDigits.isNotEmpty) {
      setState(() {
        _pinDigits.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pinBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.space12),

              // Top Logo Header: Afya
              Text(
                'Afya',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.tealPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Spacer(flex: 1),

              // Main Title: Enter your PIN
              Text(
                'Enter your PIN',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.tealDark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
                child: Text(
                  'No internet connection. Enter your PIN to continue using Afya.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF5A6E68),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),

              if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space12),
                Text(
                  widget.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.urgentAlert,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.space32),

              // 4 PIN Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pinDigits.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.tealPrimary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.tealPrimary : const Color(0xFFA0B2AC),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 2),

              // Custom 3x4 Numeric Keypad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
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

              // Bottom Link Button: Sign in with internet
              TextButton(
                onPressed: widget.onSwitchToPasswordLogin,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.tealPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Sign in with internet',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.tealPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space8),
            ],
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
        // Empty placeholder space for alignment
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
