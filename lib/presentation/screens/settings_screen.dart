import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zikermate/core/di/injection_container.dart';
import 'package:zikermate/core/theme/app_theme.dart';
import 'package:zikermate/presentation/bloc/settings_bloc.dart';
import 'package:zikermate/presentation/bloc/settings_event.dart';
import 'package:zikermate/presentation/bloc/settings_state.dart';

/// Settings screen — lets user pick a daily reminder time for dhikr notifications via SettingsBloc.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsBloc>()..add(LoadSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              );
            }

            if (state is SettingsLoaded) {
              return _buildSettingsContent(context, state.reminderTime);
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, TimeOfDay? selectedTime) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reminder Section ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: AppTheme.accentGold, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Daily Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set a daily notification to remind you to complete your dhikr.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                if (selectedTime != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryTeal.withValues(alpha: 0.15),
                          AppTheme.primaryDark.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: AppTheme.primaryTeal, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Daily',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickTime(context, selectedTime),
                        icon: Icon(
                          selectedTime != null
                              ? Icons.edit_rounded
                              : Icons.alarm_add_rounded,
                          size: 18,
                        ),
                        label: Text(
                          selectedTime != null ? 'Change Time' : 'Set Reminder',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (selectedTime != null) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => context
                            .read<SettingsBloc>()
                            .add(const UpdateReminderTime(null)),
                        icon: const Icon(Icons.notifications_off_rounded,
                            color: Color(0xFFEF5350)),
                        tooltip: 'Cancel Reminder',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFEF5350).withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── About Section ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('📿', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 12),
                    Text(
                      'ZikarMate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Your digital tasbih companion. Keep track of your daily dhikr with ease.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay? currentTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.cardDark,
              hourMinuteColor: AppTheme.cardLight,
              dialBackgroundColor: AppTheme.cardLight,
              dialHandColor: AppTheme.primaryTeal,
              entryModeIconColor: AppTheme.accentGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateReminderTime(picked));
    }
  }
}
