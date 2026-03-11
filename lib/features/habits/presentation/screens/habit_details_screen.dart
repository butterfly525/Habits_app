import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/date_only.dart';
import '../../../../core/habit_palette.dart';
import '../../domain/entities/habit.dart';
import '../controllers/habits_providers.dart';
import '../widgets/month_calendar.dart';
import '../widgets/stat_cards_grid.dart';
import 'habit_settings_screen.dart';

class HabitDetailsScreen extends ConsumerStatefulWidget {
  const HabitDetailsScreen({
    super.key,
    required this.habitId,
    required this.initialMonth,
  });

  final int habitId;
  final DateTime initialMonth;

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      habitDetailsProvider((habitId: widget.habitId, month: _currentMonth)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Привычка'),
        actions: [
          detailsAsync.when(
            data: (details) {
              return TextButton(
                onPressed: () async {
                  final settings = await Navigator.of(context).push<HabitSettingsResult>(
                    MaterialPageRoute<HabitSettingsResult>(
                      builder: (_) => HabitSettingsScreen(
                        initialTitle: details.habit.title,
                        initialColorValue: details.habit.colorValue,
                        initialTargetCount: details.habit.targetCount,
                        initialTargetPeriod: details.habit.targetPeriod,
                      ),
                    ),
                  );

                  if (settings == null) {
                    return;
                  }

                  await ref.read(habitsActionsProvider).updateHabit(
                        habitId: widget.habitId,
                        title: settings.title,
                        colorValue: settings.colorValue,
                        targetCount: settings.targetCount,
                        targetPeriod: settings.targetPeriod,
                      );
                },
                child: const Text('Изменить'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailsAsync.when(
        data: (details) {
          final completed = details.completions
              .where((item) => item.isCompleted)
              .map((item) => toDateKey(item.date))
              .toSet();
          final color = habitColorFromValue(details.habit.colorValue);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.habit.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Цель: ${details.habit.targetCount} раз ${details.habit.targetPeriod.label}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                            1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat.yMMMM().format(_currentMonth),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                            1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                MonthCalendar(
                  month: _currentMonth,
                  completedDates: completed,
                  accentColor: color,
                  onToggle: (date) async {
                    await ref.read(habitsActionsProvider).toggleCompletion(
                          habitId: widget.habitId,
                          date: date,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () async {
                        await ref.read(habitsActionsProvider).removeStatCard(widget.habitId);
                      },
                      child: const Text('-'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        await ref.read(habitsActionsProvider).addStatCard(widget.habitId);
                      },
                      child: const Text('+'),
                    ),
                    const SizedBox(width: 12),
                    const Text('Карточки статистики'),
                  ],
                ),
                const SizedBox(height: 12),
                StatCardsGrid(cards: details.statCards),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}
