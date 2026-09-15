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
    if (widget.errorMessage != null &&
        widget.errorMessage != oldWidget.errorMessage) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;
            final keySize = compact ? 60.0 : 72.0;
            final keypadGap = compact ? 12.0 : 16.0;
            final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 24.0;
            final verticalPadding = compact ? 8.0 : AppDimensions.space16;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - verticalPadding * 2,
                  ),
                  child: Column(
                    mainAxisAlignment: compact
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.space8),

                      // Top Logo Header: Afya
                      Text(
                        'Afya',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.tealPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // Main Title: Enter your PIN
                      Text(
                        'Enter your PIN',
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.tealDark,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space8),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space24),
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

                      if (widget.errorMessage != null &&
                          widget.errorMessage!.isNotEmpty) ...[
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

                      SizedBox(height: compact ? 12 : AppDimensions.space16),

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

                      SizedBox(height: compact ? 16 : AppDimensions.space24),

                      // Custom 3x4 Numeric Keypad
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space16),
                        child: Column(
                          children: [
                            _buildKeypadRow(['1', '2', '3'], keySize),
                            SizedBox(height: keypadGap),
                            _buildKeypadRow(['4', '5', '6'], keySize),
                            SizedBox(height: keypadGap),
                            _buildKeypadRow(['7', '8', '9'], keySize),
                            SizedBox(height: keypadGap),
                            _buildBottomKeypadRow(keySize),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // Bottom Link Button
                      TextButton(
                        onPressed: widget.onSwitchToPasswordLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.tealPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
          },
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, double keySize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKeyButton(key, keySize)).toList(),
    );
  }

  Widget _buildBottomKeypadRow(double keySize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Empty placeholder space for alignment
        SizedBox(width: keySize, height: keySize),
        _buildKeyButton('0', keySize),
        _buildBackspaceButton(keySize),
      ],
    );
  }

  Widget _buildKeyButton(String label, double keySize) {
    return Container(
      width: keySize,
      height: keySize,
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
                fontSize: keySize >= 72 ? 30 : 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(double keySize) {
    return Container(
      width: keySize,
      height: keySize,
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
