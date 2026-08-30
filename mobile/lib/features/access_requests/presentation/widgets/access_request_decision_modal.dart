import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/access_request_entity.dart';
import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import '../utils/countdown_timer_helper.dart';
import 'access_request_banner.dart';

/// Deep Forest Green for approve button.
const Color kDeepForestGreen = Color(0xFF014F24);

/// Mint green for consent box.
const Color kMintBackground = Color(0xFFDDF1E4);

/// Cool Gray for subtitle and deny border.
const Color kCoolGray = Color(0xFF8C9C96);

/// Modal bottom sheet for access request decision.
class AccessRequestDecisionModal extends StatelessWidget {
  final AccessRequestEntity request;
  final int secondsRemaining;

  const AccessRequestDecisionModal({
    super.key,
    required this.request,
    required this.secondsRemaining,
  });

  /// Shows the decision modal as a modal bottom sheet.
  static void show({
    required BuildContext context,
    required AccessRequestEntity request,
    required int secondsRemaining,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AccessRequestCubit>(),
        child: AccessRequestDecisionModal(
          request: request,
          secondsRemaining: secondsRemaining,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessRequestCubit, AccessRequestState>(
      builder: (context, state) {
        final isLocked =
            state is AccessRequestActionInFlight || state is AccessRequestExpired;

        final displaySeconds =
            state is AccessRequestActive ? state.secondsRemaining : secondsRemaining;
        final formattedTime =
            CountdownTimerHelper.formatRemaining(displaySeconds);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top accent bar in Gentle Coral
              Container(
                height: 8,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kGentleCoral,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),

              const SizedBox(height: 24),

              // Circular countdown container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kGentleCoral, width: 2),
                ),
                child: Center(
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kDeepCharcoal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              const Text(
                'Access Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kDeepCharcoal,
                ),
              ),

              const SizedBox(height: 12),

              // Clinic name (bold)
              Text(
                request.clinicName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kDeepCharcoal,
                ),
              ),

              const SizedBox(height: 4),

              // Doctor name and reason
              Text(
                '${request.doctorName} • ${request.reason}',
                style: const TextStyle(
                  fontSize: 14,
                  color: kCoolGray,
                ),
              ),

              const SizedBox(height: 16),

              // Mint green consent box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kMintBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: kDeepForestGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Approving this request gives doctors at this clinic access to your full medical history.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Approve button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : () {
                            context
                                .read<AccessRequestCubit>()
                                .approveRequest(request.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDeepForestGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kDeepForestGreen.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is AccessRequestActionInFlight
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Deny button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isLocked
                        ? null
                        : () {
                            context
                                .read<AccessRequestCubit>()
                                .denyRequest(request.id);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDeepForestGreen,
                      side: const BorderSide(color: kCoolGray, width: 1.5),
                      disabledForegroundColor: kCoolGray.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is AccessRequestActionInFlight
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kDeepForestGreen.withValues(alpha: 0.5),
                            ),
                          )
                        : const Text(
                            'Deny',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
