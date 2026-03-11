import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/cyberpunk_theme.dart';
import '../../../../core/date_only.dart';
import '../../../../core/habit_palette.dart';
import '../../domain/entities/habit.dart';
import '../controllers/habits_providers.dart';
import '../widgets/week_days_row.dart';
import 'habit_details_screen.dart';
import 'habit_settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsWeekProvider);
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final topBarColor = isLight ? const Color(0xE03B2858) : Colors.transparent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: topBarColor,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Мои привычки'),
        actions: const [
          ThemeModeToggleButton(),
        ],
      ),
      body: CyberpunkBackground(
        child: habitsAsync.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          data: (habits) {
            if (habits.isEmpty) {
              return const Center(
                child: Text('Пока нет привычек. Нажмите + чтобы добавить.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = habits[index];
                final color = habitColorFromValue(item.habit.colorValue);
                final now = DateTime.now();
                return Card(
                  color: color.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HabitDetailsScreen(
                                  habitId: item.habit.id,
                                  initialMonth: DateTime(now.year, now.month, 1),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.habit.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.currentPeriodCompletedCount}/${item.habit.targetCount} ${item.habit.targetPeriod.label}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: scheme.onSurface.withValues(alpha: 0.92),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        WeekDaysRow(
                          days: item.weekDays,
                          completedDates: item.completedDates,
                          accentColor: color,
                          onToggle: (day) async {
                            await ref.read(habitsActionsProvider).toggleCompletion(
                                  habitId: item.habit.id,
                                  date: dayOnly(day),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Ошибка: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final settings = await Navigator.of(context).push<HabitSettingsResult>(
            MaterialPageRoute<HabitSettingsResult>(
              builder: (_) => const HabitSettingsScreen(),
            ),
          );

          if (settings != null && settings.action == HabitSettingsAction.save) {
            await ref.read(habitsActionsProvider).addHabit(
                  title: settings.title,
                  colorValue: settings.colorValue,
                  targetCount: settings.targetCount,
                  targetPeriod: settings.targetPeriod,
                );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
