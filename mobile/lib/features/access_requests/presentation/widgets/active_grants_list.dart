import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/clinic_grant_entity.dart';
import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import 'revoke_grant_dialog.dart';

/// Displays a list of active clinic access grants.
///
/// Each card shows the clinic name, date granted, and a revoke button.
class ActiveGrantsList extends StatelessWidget {
  final List<ClinicGrantEntity> grants;

  const ActiveGrantsList({super.key, required this.grants});

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
        return _GrantCard(grant: grant);
      },
    );
  }
}

class _GrantCard extends StatelessWidget {
  final ClinicGrantEntity grant;

  const _GrantCard({required this.grant});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccessRequestCubit>().state;
    final isRevoking = state is RevokingGrant;

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

            // Date granted
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
            const SizedBox(height: 12),

            // Revoke button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isRevoking
                    ? null
                    : () {
                        RevokeGrantDialog.show(
                          context: context,
                          clinicName: grant.clinicName,
                          clinicId: grant.clinicId,
                        );
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
