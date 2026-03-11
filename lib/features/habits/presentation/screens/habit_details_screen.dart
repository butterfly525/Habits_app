import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/cyberpunk_theme.dart';
import '../../../../core/date_only.dart';
import '../../../../core/habit_palette.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_details_view.dart';
import '../../domain/entities/stat_card.dart';
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
  int? _expandedStatCardId;
  HabitDetailsView? _cachedDetails;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = habitDetailsProvider((habitId: widget.habitId, month: _currentMonth));
    final detailsAsync = ref.watch(provider);
    ref.listen<AsyncValue<HabitDetailsView>>(provider, (_, next) {
      final value = next.valueOrNull;
      if (value == null || _cachedDetails == value) {
        return;
      }

      setState(() {
        _cachedDetails = value;
      });
    });
    final visibleDetails = detailsAsync.valueOrNull ?? _cachedDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Привычка'),
        actions: [
          const ThemeModeToggleButton(),
          if (visibleDetails != null)
            TextButton(
              onPressed: () async {
                final details = visibleDetails;

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
            ),
        ],
      ),
      body: CyberpunkBackground(
        child: visibleDetails == null
            ? detailsAsync.when(
                data: (_) => const SizedBox.shrink(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Ошибка: $error')),
              )
            : _buildDetailsContent(context, visibleDetails),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, HabitDetailsView details) {
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  await ref.read(habitsActionsProvider).removeStatCard(widget.habitId);
                },
                child: const Text('-'),
              ),
              FilledButton(
                onPressed: () async {
                  await ref.read(habitsActionsProvider).addStatCard(widget.habitId);
                },
                child: const Text('+'),
              ),
              const Text('Карточки статистики'),
            ],
          ),
          const SizedBox(height: 12),
          StatCardsGrid(
            cards: details.statCards,
            habit: details.habit,
            completions: details.allCompletions,
            expandedCardId: _expandedStatCardId,
            onCardTap: (card) {
              setState(() {
                _expandedStatCardId = _expandedStatCardId == card.id ? null : card.id;
              });
            },
            onSelectType: (card, type) async {
              await _handleStatCardTypeSelection(card, type);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatCardTypeSelection(StatCard card, StatCardType type) async {
    String? noteText = card.noteText;
    if (type == StatCardType.note) {
      noteText = await _showNoteDialog(initialValue: card.noteText);
      if (noteText == null) {
        return;
      }
    }

    await ref.read(habitsActionsProvider).updateStatCard(
          cardId: card.id,
          type: type,
          noteText: type == StatCardType.note ? noteText : '',
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _expandedStatCardId = null;
    });
  }

  Future<String?> _showNoteDialog({required String initialValue}) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Заметка'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Введите текст заметки',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}
