import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/entities/access_request_entity.dart';
import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import '../../../../core/utils/countdown_timer_helper.dart';

class AccessRequestDecisionModal extends StatelessWidget {
  final AccessRequestEntity request;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const AccessRequestDecisionModal({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onDeny,
  });

  static void show({
    required BuildContext context,
    required AccessRequestEntity request,
    required VoidCallback onApprove,
    required VoidCallback onDeny,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x66121E1A), // Overlay on-surface/40
      builder: (_) => BlocProvider.value(
        value: context.read<AccessRequestCubit>(),
        child: PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: AccessRequestDecisionModal(
              request: request,
              onApprove: onApprove,
              onDeny: onDeny,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessRequestCubit, AccessRequestState>(
      builder: (context, state) {
        final isLocked = state is AccessRequestSubmitting || state is AccessRequestExpired;

        String formattedTime = '0:00';
        if (state is AccessRequestActive) {
          formattedTime = state.formattedTime;
        } else if (state is AccessRequestSubmitting || state is AccessRequestExpired) {
          formattedTime = '0:00';
        } else {
          final initialSeconds = CountdownTimerHelper.remainingSeconds(request.expiresAt);
          formattedTime = CountdownTimerHelper.formatSeconds(initialSeconds);
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // surface-container-lowest
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD8E6DF)), // surface-variant
            boxShadow: const [
              BoxShadow(
                color: Color(0x14687570), // rgba(104, 117, 112, 0.08)
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Accent Bar
              Container(
                height: 8,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3C9C9), // gentle-coral
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),

              const SizedBox(height: 32),

              // Countdown Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7F0), // surface-container-low
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3C9C9), width: 2), // gentle-coral
                ),
                alignment: Alignment.center,
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600, // semi-bold
                    fontSize: 20,
                    color: Color(0xFF333333), // text-deep-charcoal
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Modal Header
              const Text(
                'Access Request',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600, // semi-bold
                  fontSize: 24,
                  color: Color(0xFF121E1A), // text-on-surface
                ),
              ),

              const SizedBox(height: 12),

              // Request Body Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF8C9C96), // text-cool-gray
                    ),
                    children: [
                      TextSpan(
                        text: request.clinicName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' has requested access to your medical history.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Consent Callout Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16), // p-md
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF1E4), // mint
                    borderRadius: BorderRadius.circular(12), // rounded-xl
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline,
                          color: Color(0xFF026B32), // primary
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Approving this request gives doctors at this clinic access to your full medical history.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF121E1A),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Primary Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLocked ? null : onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF014F24), // deep-forest-green
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF014F24).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: (state is AccessRequestSubmitting && state.isApproving)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Approve Access',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600, // semi-bold
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isLocked ? null : onDeny,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF014F24), // deep-forest-green
                      side: const BorderSide(color: Color(0xFF8C9C96), width: 2), // cool-gray
                      disabledForegroundColor: const Color(0xFF014F24).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (state is AccessRequestSubmitting && !state.isApproving)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF014F24).withValues(alpha: 0.5),
                            ),
                          )
                        : const Text(
                            'Deny',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600, // semi-bold
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
