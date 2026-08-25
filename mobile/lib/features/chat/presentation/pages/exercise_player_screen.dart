import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Screen that plays/guides the user through a suggested exercise.
///
/// Receives the [exerciseId] from the chat flow so the correct exercise
/// content can be loaded and tracked.
class ExercisePlayerScreen extends StatelessWidget {
  final String exerciseId;

  const ExercisePlayerScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    // Derive a human-readable name from the id (placeholder logic).
    final String exerciseName =
        exerciseId.toLowerCase().contains('sleep') ? 'Sleep' : 'Exercise';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$exerciseName Exercise',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE1F5FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF0288D1),
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                '$exerciseName Exercise',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Exercise ID: $exerciseId',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Exercise player coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
