import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/clinic_grant_entity.dart';
import '../bloc/grants_management_bloc.dart';

/// The main Access tab — shows all health centers the user has visited.
class PendingAccessRequestsScreen extends StatelessWidget {
  const PendingAccessRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GrantsManagementBloc>()..add(FetchActiveGrantsEvent()),
      child: const _MyHealthCentersView(),
    );
  }
}

class _MyHealthCentersView extends StatelessWidget {
  const _MyHealthCentersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Afya',
          style: TextStyle(
            color: Color(0xFF0C6B44),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocBuilder<GrantsManagementBloc, GrantsManagementState>(
          builder: (context, state) {
            // Loading
            if (state is GrantsManagementInitial ||
                state is GrantsManagementLoading) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C6B44),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Error
            if (state is GrantsManagementError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load health centers',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E252B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<GrantsManagementBloc>()
                                  .add(FetchActiveGrantsEvent()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C6B44),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Loaded
            if (state is GrantsManagementLoaded) {
              final grants = state.grants;

              if (grants.isEmpty) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(),
                    Expanded(child: _EmptyState()),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF0C6B44),
                      onRefresh: () async {
                        context
                            .read<GrantsManagementBloc>()
                            .add(FetchActiveGrantsEvent());
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        itemCount: grants.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _HealthCenterCard(grant: grants[index]),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section header below the AppBar
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(
        'My Health Centers',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E252B),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                size: 56,
                color: Color(0xFF0C6B44),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Health Centers Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E252B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clinics and hospitals you visit will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7A75),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Health center card (smooth, clear white, clickable)
// ─────────────────────────────────────────────
class _HealthCenterCard extends StatelessWidget {
  final ClinicGrantEntity grant;

  const _HealthCenterCard({required this.grant});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Today';
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Pick an icon based on keywords in the clinic name.
  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('hospital') || n.contains('medical college')) {
      return Icons.local_hospital_rounded;
    }
    if (n.contains('clinic') || n.contains('health center')) {
      return Icons.medical_services_rounded;
    }
    return Icons.local_hospital_outlined;
  }

  String _facilityTypeFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('specialized hospital')) {
      return 'Specialized Tertiary Hospital';
    }
    if (n.contains('medical college')) {
      return 'Teaching Hospital & Medical College';
    }
    if (n.contains('medical center')) {
      return 'Comprehensive Medical Center';
    }
    if (n.contains('clinic')) {
      return 'Outpatient Clinic';
    }
    return 'General Health Center';
  }

  void _showHealthCenterDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE4E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with icon and name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _iconFor(grant.clinicName),
                        color: const Color(0xFF0C6B44),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grant.clinicName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E252B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5EE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Verified Healthcare Provider',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0C6B44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFEDF2F0), height: 1),
                const SizedBox(height: 16),

                // Details List
                _buildDetailItem(
                  icon: Icons.category_outlined,
                  title: 'Facility Type',
                  value: _facilityTypeFor(grant.clinicName),
                ),
                const SizedBox(height: 14),
                _buildDetailItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Last Visit Date',
                  value: DateFormat('EEEE, dd MMMM yyyy').format(grant.grantedAt),
                ),
                const SizedBox(height: 14),
                _buildDetailItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: 'Addis Ababa, Ethiopia',
                ),
                const SizedBox(height: 14),
                _buildDetailItem(
                  icon: Icons.folder_shared_outlined,
                  title: 'Records Available',
                  value: 'Consultations, Diagnoses & Prescriptions',
                ),
                const SizedBox(height: 14),
                _buildDetailItem(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Health Record Link',
                  value: 'Connected & Synchronized',
                  valueColor: const Color(0xFF0C6B44),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E252B),
                          side: const BorderSide(color: Color(0xFFDCE4E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/history');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C6B44),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'View Records',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF5A6E78)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7A75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1E252B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHealthCenterDetails(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFor(grant.clinicName),
                    color: const Color(0xFF0C6B44),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Name & date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        grant.clinicName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E252B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF6B7A75),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last visit: ${_formatDate(grant.grantedAt)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7A75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0BEC5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
