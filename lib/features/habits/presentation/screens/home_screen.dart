import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои привычки'),
      ),
      body: habitsAsync.when(
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
                color: color.withValues(alpha: 0.10),
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
                                    style: Theme.of(context).textTheme.bodyMedium,
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
                          await ref
                              .read(habitsActionsProvider)
                              .toggleCompletion(habitId: item.habit.id, date: dayOnly(day));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final settings = await Navigator.of(context).push<HabitSettingsResult>(
            MaterialPageRoute<HabitSettingsResult>(
              builder: (_) => const HabitSettingsScreen(),
            ),
          );

          if (settings != null) {
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
