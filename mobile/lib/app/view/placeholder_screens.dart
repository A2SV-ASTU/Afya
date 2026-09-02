import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/afya_button.dart';

class DashboardPlaceholderScreen extends StatelessWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Dashboard (Assigned to Elham & Yehabesha)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encounters History', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Encounters History (Assigned to Freweld)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Patient Profile (Assigned to Yehabesha)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class ChatPlaceholderScreen extends StatelessWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Chat Screen (Placeholder)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class AccessPlaceholderScreen extends StatelessWidget {
  const AccessPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Access Screen (Placeholder)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class AccessDecisionPlaceholderScreen extends StatelessWidget {
  final String id;

  const AccessDecisionPlaceholderScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Consent Decision', style: AppTypography.titleMedium)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Request ID: $id', style: AppTypography.bodyLarge),
              const SizedBox(height: 8),
              const Text('Deep-Link Handling (Assigned to Wendmagegn)', style: AppTypography.bodyMedium),
              const SizedBox(height: 24),
              AfyaButton(
                text: 'Back to Dashboard',
                onPressed: () => Navigator.of(context).pop(),
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInPlaceholderScreen extends StatelessWidget {
  const SignInPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Sign In Screen (Assigned to Abel)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class SignUpPlaceholderScreen extends StatelessWidget {
  const SignUpPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up', style: AppTypography.titleMedium)),
      body: const Center(
        child: Text('Sign Up Screen (Assigned to Abel)', style: AppTypography.bodyMedium),
      ),
    );
  }
}

class SplashPlaceholderScreen extends StatelessWidget {
  const SplashPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
