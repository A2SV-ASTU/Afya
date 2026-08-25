import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/presentation/pages/exercise_player_screen.dart';
import 'package:mobile/features/chat/presentation/widgets/exercise_confirm_modal.dart';

/// A card displayed below a chat bubble suggesting an exercise the user
/// can try.
///
/// Tapping "Yes, let's try" opens an [ExerciseConfirmModal] dialog. When
/// the user confirms, they are routed to [ExercisePlayerScreen].
///
/// Tapping "No, thanks" dismisses the card from view.
class SuggestedExerciseCard extends StatefulWidget {
  final String exerciseId;

  const SuggestedExerciseCard({
    super.key,
    required this.exerciseId,
  });

  @override
  State<SuggestedExerciseCard> createState() => _SuggestedExerciseCardState();
}

class _SuggestedExerciseCardState extends State<SuggestedExerciseCard> {
  bool _dismissed = false;

  void _onConfirmExercise() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercisePlayerScreen(
          exerciseId: widget.exerciseId,
        ),
      ),
    );
  }

  void _onDismiss() {
    setState(() {
      _dismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    // In a real app, this would be looked up from an exercise provider/repository.
    final String exerciseName =
        widget.exerciseId.toLowerCase().contains('sleep') ? 'Sleep' : 'Exercise';

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE1F5FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.moon,
                  color: Color(0xFF0288D1),
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try the $exerciseName exercise?',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'It can help you relax and prepare for better rest.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => ExerciseConfirmModal(
                        exerciseName: exerciseName,
                        onConfirm: _onConfirmExercise,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: const Text(
                    'Yes, let\'s try',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: OutlinedButton(
                  onPressed: _onDismiss,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: const Text(
                    'No, thanks',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
