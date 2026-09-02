import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/afya_card.dart';

class TodayAdherenceCard extends StatelessWidget {
  final int takenCount;
  final int pendingCount;
  final int missedCount;
  final int skippedCount;
  final int totalCount;
  final int adherencePercentage;

  const TodayAdherenceCard({
    super.key,
    required this.takenCount,
    required this.pendingCount,
    required this.missedCount,
    this.skippedCount = 0,
    required this.totalCount,
    required this.adherencePercentage,
  });

  String get _motivationalMessage {
    if (totalCount == 0) return '';
    if (adherencePercentage == 100) {
      return 'Great job! All doses taken today!';
    }
    if (adherencePercentage >= 50) {
      return "You're doing well today!";
    }
    return 'Keep going! Remember your scheduled doses.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Adherence",
              style: AppTypography.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space8,
                vertical: AppDimensions.space4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                'Today',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),

        // Content Card
        if (totalCount == 0)
          _buildEmptyCard()
        else
          _buildPopulatedCard(),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return AfyaCard(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountColumn('Taken', 0, AppColors.success),
              _buildCountColumn('Missed', 0, AppColors.urgentAlert),
              _buildCountColumn('Pending', 0, AppColors.warning),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'Your adherence summary will appear here once your first medication is prescribed.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedCard() {
    return AfyaCard(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular progress indicator with percentage
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: totalCount > 0
                            ? (adherencePercentage / 100.0).clamp(0.0, 1.0)
                            : 0.0,
                        strokeWidth: 7.0,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$adherencePercentage%',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Adherence',
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space20),

              // Legend items
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      color: AppColors.success,
                      text:
                          'Taken $takenCount dose${takenCount == 1 ? '' : 's'}',
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    _buildLegendItem(
                      color: AppColors.warning,
                      text:
                          'Pending $pendingCount dose${pendingCount == 1 ? '' : 's'}',
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    _buildLegendItem(
                      color: AppColors.urgentAlert,
                      text:
                          'Missed $missedCount dose${missedCount == 1 ? '' : 's'}',
                    ),
                    if (skippedCount > 0) ...[
                      const SizedBox(height: AppDimensions.space8),
                      _buildLegendItem(
                        color: AppColors.textSecondary,
                        text:
                            'Skipped $skippedCount dose${skippedCount == 1 ? '' : 's'}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_motivationalMessage.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppDimensions.space12),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    _motivationalMessage,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          '$count',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
