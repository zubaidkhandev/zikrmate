import 'package:flutter/material.dart';
import 'package:zikermate/core/theme/app_theme.dart';

/// Styled progress bar — shows daily goal progress with color change on completion.
class ProgressBar extends StatelessWidget {
  final int currentCount;
  final int targetCount;

  const ProgressBar({
    super.key,
    required this.currentCount,
    required this.targetCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetCount > 0
        ? (currentCount / targetCount).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = currentCount >= targetCount;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.progressBg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppTheme.accentGold : AppTheme.primaryTeal,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% — $currentCount / $targetCount',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isComplete ? AppTheme.accentGold : AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
