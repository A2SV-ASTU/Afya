import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/grants_management_bloc.dart';
import '../widgets/clinic_grant_card.dart';
import '../widgets/revoke_confirm_dialog.dart';

class ClinicGrantsScreen extends StatefulWidget {
  const ClinicGrantsScreen({super.key});

  @override
  State<ClinicGrantsScreen> createState() => _ClinicGrantsScreenState();
}

class _ClinicGrantsScreenState extends State<ClinicGrantsScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming Bloc is provided above this screen
    context.read<GrantsManagementBloc>().add(FetchActiveGrantsEvent());
  }

  void _showRevokeDialog(BuildContext context, String clinicId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return RevokeConfirmDialog(
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            context.read<GrantsManagementBloc>().add(RevokeGrantEvent(clinicId));
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFDF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFDF6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121E1A)),
        title: const Text(
          'Active Clinic Grants',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF121E1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<GrantsManagementBloc, GrantsManagementState>(
        listener: (context, state) {
          if (state is GrantsManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFD32F2F),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GrantsManagementLoading || state is GrantsManagementInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF014F24),
              ),
            );
          }

          if (state is GrantsManagementLoaded) {
            if (state.grants.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 64,
                        color: Color(0xFF8C9C96),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Active Grants',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF121E1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You currently have no active clinic access grants.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF8C9C96),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GrantsManagementBloc>().add(FetchActiveGrantsEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF014F24),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF014F24),
              onRefresh: () async {
                context.read<GrantsManagementBloc>().add(FetchActiveGrantsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.grants.length,
                itemBuilder: (context, index) {
                  final grant = state.grants[index];
                  return ClinicGrantCard(
                    grant: grant,
                    onRevoke: () => _showRevokeDialog(context, grant.clinicId),
                  );
                },
              ),
            );
          }

          // Error state fallback
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load grants',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF121E1A),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<GrantsManagementBloc>().add(FetchActiveGrantsEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014F24),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
