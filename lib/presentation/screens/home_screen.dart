import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zikermate/core/theme/app_theme.dart';
import 'package:zikermate/presentation/bloc/dhikr_bloc.dart';
import 'package:zikermate/presentation/bloc/dhikr_event.dart';
import 'package:zikermate/presentation/bloc/dhikr_state.dart';
import 'package:zikermate/presentation/screens/settings_screen.dart';
import 'package:zikermate/presentation/widgets/dhikr_card.dart';
import 'package:zikermate/presentation/widgets/progress_bar.dart';
import 'package:zikermate/presentation/widgets/counter_button.dart';

/// Main screen — displays dhikr selector, counter, progress bar, and controls.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DhikrBloc, DhikrState>(
          builder: (context, state) {
            if (state is DhikrLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              );
            }

            if (state is DhikrError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppTheme.accentGold),
                    const SizedBox(height: 16),
                    Text(state.message,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            if (state is DhikrLoaded) {
              return _buildLoadedUI(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<DhikrBloc, DhikrState>(
        builder: (context, state) {
          if (state is! DhikrLoaded) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showAddDhikrDialog(context),
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
    );
  }

  Widget _buildLoadedUI(BuildContext context, DhikrLoaded state) {
    final selected = state.selectedDhikr;
    final isComplete = selected.currentCount >= selected.targetCount;

    return Column(
      children: [
        // ── App Bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text(
                '📿 ZikarMate',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings_rounded,
                    color: AppTheme.accentGold),
              ),
            ],
          ),
        ),

        // ── Dhikr Selector Row ──
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.dhikrs.length,
            itemBuilder: (context, index) {
              final dhikr = state.dhikrs[index];
              return DhikrCard(
                name: dhikr.name,
                isSelected: dhikr.id == state.selectedId,
                currentCount: dhikr.currentCount,
                targetCount: dhikr.targetCount,
                onTap: () => context
                    .read<DhikrBloc>()
                    .add(SelectDhikr(dhikr.id)),
              );
            },
          ),
        ),

        const Spacer(flex: 1),

        // ── Dhikr Name ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            selected.name,
            key: ValueKey(selected.id),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isComplete ? AppTheme.accentGold : AppTheme.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Counter Display ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '${selected.currentCount}',
            key: ValueKey(selected.currentCount),
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              color: isComplete ? AppTheme.accentGold : AppTheme.textPrimary,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Progress Bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ProgressBar(
            currentCount: selected.currentCount,
            targetCount: selected.targetCount,
          ),
        ),

        // ── Completion Message ──
        if (isComplete) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold.withValues(alpha: 0.15),
                  AppTheme.accentGold.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    color: AppTheme.accentGold, size: 20),
                SizedBox(width: 8),
                Text(
                  'MashaAllah! Goal completed ✨',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(flex: 2),

        // ── Counter Button ──
        CounterButton(
          isComplete: isComplete,
          onPressed: () => context
              .read<DhikrBloc>()
              .add(IncrementDhikr(selected.id)),
        ),

        const SizedBox(height: 24),

        // ── Action Buttons ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionButton(
              icon: Icons.refresh_rounded,
              label: 'Reset',
              color: const Color(0xFFEF5350),
              onTap: () => _confirmReset(context, selected.id, selected.name),
            ),
            const SizedBox(width: 24),
            _actionButton(
              icon: Icons.flag_rounded,
              label: 'Goal',
              color: AppTheme.accentGold,
              onTap: () => _showSetGoalDialog(context, selected.id,
                  selected.targetCount),
            ),
            const SizedBox(width: 24),
            _actionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppTheme.textSecondary,
              onTap: () =>
                  _confirmDelete(context, selected.id, selected.name),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Counter'),
        content: Text('Reset "$name" back to 0?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DhikrBloc>().add(ResetDhikr(id));
              Navigator.pop(ctx);
            },
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Dhikr'),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DhikrBloc>().add(DeleteDhikr(id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  void _showSetGoalDialog(
      BuildContext context, String id, int currentTarget) {
    final controller =
        TextEditingController(text: currentTarget.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target Count',
            hintText: 'e.g. 33, 100, 1000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final target = int.tryParse(controller.text);
              if (target != null && target > 0) {
                context
                    .read<DhikrBloc>()
                    .add(SetGoalEvent(id, target));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDhikrDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '33');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Dhikr'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Dhikr Name',
                hintText: 'e.g. SubhanAllahi wa bihamdihi',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Count',
                hintText: 'e.g. 33, 100',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final target =
                  int.tryParse(targetController.text) ?? 33;
              if (name.isNotEmpty) {
                context
                    .read<DhikrBloc>()
                    .add(AddCustomDhikrEvent(name, target));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
