import 'package:flutter/material.dart';
import 'package:zikermate/core/theme/app_theme.dart';

/// Selectable dhikr chip — highlights when active, dispatches selection on tap.
class DhikrCard extends StatelessWidget {
  final String name;
  final bool isSelected;
  final int currentCount;
  final int targetCount;
  final VoidCallback onTap;

  const DhikrCard({
    super.key,
    required this.name,
    required this.isSelected,
    required this.currentCount,
    required this.targetCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = currentCount >= targetCount;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isComplete
                      ? [AppTheme.accentGold, const Color(0xFFF9A825)]
                      : [AppTheme.primaryTeal, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isComplete ? AppTheme.accentGold : AppTheme.primaryTeal)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$currentCount/$targetCount',
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
