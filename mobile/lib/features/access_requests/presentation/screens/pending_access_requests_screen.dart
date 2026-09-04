import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/pending_access_requests_bloc.dart';
import '../widgets/access_request_card.dart';

class PendingAccessRequestsScreen extends StatelessWidget {
  const PendingAccessRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PendingAccessRequestsBloc>()..add(FetchPendingAccessRequestsEvent()),
      child: const PendingAccessRequestsView(),
    );
  }
}

class PendingAccessRequestsView extends StatefulWidget {
  const PendingAccessRequestsView({super.key});

  @override
  State<PendingAccessRequestsView> createState() =>
      _PendingAccessRequestsViewState();
}

class _PendingAccessRequestsViewState extends State<PendingAccessRequestsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFDF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFDF6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121E1A)),
        title: const Text(
          'Access Requests',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF121E1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<PendingAccessRequestsBloc, PendingAccessRequestsState>(
        listener: (context, state) {
          if (state is PendingAccessRequestsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFD32F2F),
              ),
            );
          } else if (state is AccessRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF014F24),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PendingAccessRequestsLoading ||
              state is PendingAccessRequestsInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF014F24),
              ),
            );
          }

          if (state is PendingAccessRequestsLoaded ||
              state is AccessRequestActionSuccess) {
            final requests = state is PendingAccessRequestsLoaded
                ? state.requests
                : (state as AccessRequestActionSuccess).requests;

            if (requests.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 64,
                        color: Color(0xFF8C9C96),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Pending Requests',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF121E1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You have no pending access requests from clinics.\nWhen a clinic requests access to your records, it will appear here.',
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
                          context
                              .read<PendingAccessRequestsBloc>()
                              .add(FetchPendingAccessRequestsEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF014F24),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                context
                    .read<PendingAccessRequestsBloc>()
                    .add(FetchPendingAccessRequestsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return AccessRequestCard(
                    request: request,
                    onApprove: () => _showApproveDialog(context, request),
                    onDeny: () => _showDenyDialog(context, request),
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
                  'Failed to load requests',
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
                    context
                        .read<PendingAccessRequestsBloc>()
                        .add(FetchPendingAccessRequestsEvent());
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

  void _showApproveDialog(
      BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Approve Access?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF121E1A),
            ),
          ),
          content: Text(
            'Allow ${request.clinicName} to access your medical records? '
            'You can revoke this access at any time from Active Clinic Grants.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF8C9C96),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF8C9C96),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<PendingAccessRequestsBloc>()
                    .add(ApproveAccessRequestEvent(request.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF014F24),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDenyDialog(
      BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Deny Access?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF121E1A),
            ),
          ),
          content: Text(
            'Are you sure you want to deny ${request.clinicName} access to your records?',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF8C9C96),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF8C9C96),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<PendingAccessRequestsBloc>()
                    .add(DenyAccessRequestEvent(request.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Deny',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
