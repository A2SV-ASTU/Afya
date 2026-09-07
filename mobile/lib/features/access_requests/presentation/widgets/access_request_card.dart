import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/access_request_entity.dart';

import 'countdown_timer_widget.dart';

class AccessRequestCard extends StatelessWidget {
  final AccessRequestEntity request;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final VoidCallback? onExpired;

  const AccessRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onDeny,
    this.onExpired,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(request.createdAt);
    final bool isExpired = request.expiresAt.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E6DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14687570),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clinic name and urgency badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.clinicName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF121E1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CountdownTimerWidget(
                expiresAt: request.expiresAt,
                onTimerComplete: onExpired,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Doctor name
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: Color(0xFF8C9C96),
              ),
              const SizedBox(width: 4),
              Text(
                'Requested by ${request.doctorName}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF8C9C96),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Date
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Color(0xFF8C9C96),
              ),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF8C9C96),
                ),
              ),
            ],
          ),

          // Reason (if provided)
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EDE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C9C96),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.reason,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isExpired ? null : onDeny,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isExpired ? null : onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014F24),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
