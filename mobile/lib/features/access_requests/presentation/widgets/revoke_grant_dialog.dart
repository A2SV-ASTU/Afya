import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/access_request_cubit.dart';

/// Confirmation dialog for revoking a clinic access grant.
///
/// Asks the user: "Are you sure you want to revoke medical record access
/// for [Clinic Name]?" and triggers [RevokeClinicGrantUseCase] on confirm.
class RevokeGrantDialog extends StatelessWidget {
  final String clinicName;
  final String clinicId;

  const RevokeGrantDialog({
    super.key,
    required this.clinicName,
    required this.clinicId,
  });

  /// Shows the revoke confirmation dialog.
  static Future<void> show({
    required BuildContext context,
    required String clinicName,
    required String clinicId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AccessRequestCubit>(),
        child: RevokeGrantDialog(
          clinicName: clinicName,
          clinicId: clinicId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Revoke Access',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to revoke medical record access for $clinicName?',
        style: const TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AccessRequestCubit>().revokeGrant(clinicId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Revoke'),
        ),
      ],
    );
  }
}
