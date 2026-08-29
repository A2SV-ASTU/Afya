import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/access_request_cubit.dart';
import '../bloc/access_request_state.dart';
import '../widgets/active_grants_list.dart';

/// Page that displays the user's active clinic access grants.
///
/// Uses [AccessRequestCubit.fetchActiveGrants] to load data and
/// shows loading, error, and populated states accordingly.
class ActiveGrantsPage extends StatefulWidget {
  const ActiveGrantsPage({super.key});

  @override
  State<ActiveGrantsPage> createState() => _ActiveGrantsPageState();
}

class _ActiveGrantsPageState extends State<ActiveGrantsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccessRequestCubit>().fetchActiveGrants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Grants'),
        centerTitle: true,
      ),
      body: BlocBuilder<AccessRequestCubit, AccessRequestState>(
        builder: (context, state) {
          if (state is ActiveGrantsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ActiveGrantsFailure) {
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
                        context.read<AccessRequestCubit>().fetchActiveGrants();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ActiveGrantsLoaded) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AccessRequestCubit>().fetchActiveGrants(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ActiveGrantsList(grants: state.grants),
                ],
              ),
            );
          }

          if (state is RevokingGrant) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AccessRequestCubit>().fetchActiveGrants(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ActiveGrantsList(grants: state.grants),
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
