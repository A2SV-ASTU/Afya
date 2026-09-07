import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/clinic_grants_bloc.dart';
import '../widgets/active_grants_list.dart';

/// Page that displays the user's active clinic access grants.
///
/// Uses [ClinicGrantsBloc] to load data and
/// shows loading, error, and populated states accordingly.
class ActiveGrantsPage extends StatefulWidget {
  const ActiveGrantsPage({super.key});

  @override
  State<ActiveGrantsPage> createState() => _ActiveGrantsPageState();
}

class _ActiveGrantsPageState extends State<ActiveGrantsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ClinicGrantsBloc>().add(FetchActiveGrantsEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ClinicGrantsBloc>().add(RecalculateTimersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Grants'),
        centerTitle: true,
      ),
      body: BlocConsumer<ClinicGrantsBloc, ClinicGrantsState>(
        listener: (context, state) {
          if (state is ClinicGrantsLoaded && state.autoExpiredClinicId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Temporary access session has expired."),
                backgroundColor: Color(0xFFD32F2F),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClinicGrantsLoading || state is ClinicGrantsInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClinicGrantsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ClinicGrantsBloc>().add(FetchActiveGrantsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ClinicGrantsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClinicGrantsBloc>().add(FetchActiveGrantsEvent());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ActiveGrantsList(
                    grants: state.grants,
                    remainingSecondsMap: state.remainingSecondsMap,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
