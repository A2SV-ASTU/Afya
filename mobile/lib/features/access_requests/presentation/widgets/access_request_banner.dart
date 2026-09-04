import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import 'access_request_decision_modal.dart';

class AccessRequestBanner extends StatelessWidget {
  const AccessRequestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessRequestCubit, AccessRequestState>(
      builder: (context, state) {
        if (state is! AccessRequestActive) {
          return const SizedBox.shrink();
        }

        final request = state.request;

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
                  request: request,
                  onApprove: () {
                    context.read<AccessRequestCubit>().approveRequest(request.id);
                  },
                  onDeny: () {
                    context.read<AccessRequestCubit>().denyRequest(request.id);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD32F2F),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            request.clinicName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Requested by ${request.doctorName}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.formattedTime,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
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
