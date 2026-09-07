import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/clinic_grant_entity.dart';
import '../bloc/clinic_grants_bloc.dart';
import 'revoke_grant_dialog.dart';

/// Displays a list of active clinic access grants.
class ActiveGrantsList extends StatelessWidget {
  final List<ClinicGrantEntity> grants;
  final Map<String, int> remainingSecondsMap;

  const ActiveGrantsList({
    super.key,
    required this.grants,
    required this.remainingSecondsMap,
  });

  @override
  Widget build(BuildContext context) {
    if (grants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No active clinic access grants.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grants.length,
      itemBuilder: (context, index) {
        final grant = grants[index];
        final remainingSeconds = remainingSecondsMap[grant.clinicId] ?? 0;
        return _GrantCard(grant: grant, remainingSeconds: remainingSeconds);
      },
    );
  }
}

class _GrantCard extends StatelessWidget {
  final ClinicGrantEntity grant;
  final int remainingSeconds;

  const _GrantCard({required this.grant, required this.remainingSeconds});

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isRevoking = false; // Add real revoke loading check if needed

    final bool isWarning = remainingSeconds < 60;

    final Color badgeBg = isWarning ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final Color badgeText = isWarning ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic name
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  color: Color(0xFF1B7A43),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    grant.clinicName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date granted and Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Granted: ${_formatDate(grant.grantedAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    _formatTime(remainingSeconds),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Revoke button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isRevoking
                    ? null
                    : () {
                        context.read<ClinicGrantsBloc>().add(RevokeClinicGrantEvent(grant.clinicId));
                      },
                icon: isRevoking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.block, size: 18),
                label: const Text('Revoke Access'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
