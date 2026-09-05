import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_button.dart';
import '../../../../core/widgets/afya_text_field.dart';

class SkipReasonDialog extends StatefulWidget {
  const SkipReasonDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SkipReasonDialog(),
    );
  }

  @override
  State<SkipReasonDialog> createState() => _SkipReasonDialogState();
}

class _SkipReasonDialogState extends State<SkipReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isValid = _controller.text.trim().isNotEmpty;
    if (isValid != _canSubmit) {
      setState(() {
        _canSubmit = isValid;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _confirmSkip() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) {
      Navigator.of(context).pop(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppDimensions.space16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skip this dose?',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Why are you skipping this dose?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                AfyaTextField(
                  label: 'Reason for skipping',
                  hint: 'e.g., Side effects, nausea, doctor advised...',
                  controller: _controller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A skip reason is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),
                Row(
                  children: [
                    Expanded(
                      child: AfyaButton(
                        text: 'Cancel',
                        isSecondary: true,
                        onPressed: () => Navigator.of(context).pop(null),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: AfyaButton(
                        text: 'Confirm Skip',
                        onPressed: _canSubmit ? _confirmSkip : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
