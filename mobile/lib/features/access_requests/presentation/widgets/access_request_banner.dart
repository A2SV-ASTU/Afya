import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import '../utils/countdown_timer_helper.dart';
import 'access_request_decision_modal.dart';

/// Gentle Coral accent color.
const Color kGentleCoral = Color(0xFFF3C9C9);

/// Deep Charcoal for timer text.
const Color kDeepCharcoal = Color(0xFF333333);

/// Floating top banner that shows when an access request is active.
/// Displays clinic name and countdown timer. Tapping opens the decision modal.
class AccessRequestBanner extends StatelessWidget {
  const AccessRequestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessRequestCubit, AccessRequestState>(
      builder: (context, state) {
        if (state is! AccessRequestActive) {
          return const SizedBox.shrink();
        }

        final formattedTime =
            CountdownTimerHelper.formatRemaining(state.secondsRemaining);

        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                AccessRequestDecisionModal.show(
                  context: context,
                  request: state.request,
                  secondsRemaining: state.secondsRemaining,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kGentleCoral,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.medical_information_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.request.clinicName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: kDeepCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Access request pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: kGentleCoral,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kDeepCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
