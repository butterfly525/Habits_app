import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/date_only.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/entities/stat_card.dart';

class StatCardsGrid extends StatelessWidget {
  const StatCardsGrid({
    super.key,
    required this.cards,
    required this.habit,
    required this.completions,
    required this.expandedCardId,
    required this.onCardTap,
    required this.onSelectType,
  });

  final List<StatCard> cards;
  final Habit habit;
  final List<HabitCompletion> completions;
  final int? expandedCardId;
  final ValueChanged<StatCard> onCardTap;
  final Future<void> Function(StatCard card, StatCardType type) onSelectType;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = scheme.onSurface;
    final valueColor = scheme.onSurface;
    final subtitleColor = scheme.onSurface.withValues(alpha: isDark ? 0.74 : 0.62);
    const spacing = 8.0;
    const cardHeight = 188.0;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width - 32 - spacing) / 2;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: cards.map((card) {
        final isExpanded = expandedCardId == card.id;
        final summary = _buildSummary(card);
        final hideCollapsedPrompt = isExpanded && card.type == StatCardType.empty;

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Material(
            color: scheme.surface.withValues(alpha: isDark ? 0.52 : 0.68),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onCardTap(card),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: isDark ? 0.42 : 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if (!hideCollapsedPrompt) ...[
                      const SizedBox(height: 8),
                      Text(
                        summary.value,
                        maxLines: isExpanded ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: valueColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (summary.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          summary.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: subtitleColor,
                              ),
                        ),
                      ],
                    ],
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _availableTypes.map((type) {
                                final isSelected = card.type == type;
                                return ChoiceChip(
                                  backgroundColor: scheme.surface.withValues(
                                    alpha: isDark ? 0.84 : 0.92,
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? scheme.onPrimary
                                        : valueColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  selectedColor: scheme.primary,
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0x6600F6FF)
                                        : const Color(0x33FF8C42),
                                  ),
                                  label: Text(type.title),
                                  selected: isSelected,
                                  onSelected: (_) => onSelectType(card, type),
                                );
                              }).toList(growable: false),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  _StatCardSummary _buildSummary(StatCard card) {
    final completedDates = completions
        .where((item) => item.isCompleted)
        .map((item) => dayOnly(item.date))
        .toList(growable: false)
      ..sort();

    switch (card.type) {
      case StatCardType.empty:
        return const _StatCardSummary(
          title: 'Выберите статистику',
          value: 'Нажмите на карточку',
          subtitle: '',
        );
      case StatCardType.streak:
        final streak = _calculateStreak(completedDates);
        return _StatCardSummary(
          title: StatCardType.streak.title,
          value: '$streak',
          subtitle: _pluralizeDays(streak),
        );
      case StatCardType.progressPercent:
        final completedCount = _completedCountForCurrentPeriod();
        final percent =
            habit.targetCount == 0 ? 0 : ((completedCount / habit.targetCount) * 100).round();
        final clampedPercent = math.min(percent, 100);
        return _StatCardSummary(
          title: StatCardType.progressPercent.title,
          value: '$clampedPercent%',
          subtitle: '$completedCount/${habit.targetCount} ${habit.targetPeriod.label}',
        );
      case StatCardType.daysCompleted:
        final total = completedDates.length;
        return _StatCardSummary(
          title: StatCardType.daysCompleted.title,
          value: '$total',
          subtitle: _pluralizeDays(total),
        );
      case StatCardType.daysRemaining:
        final remaining = _daysRemainingInPeriod();
        return _StatCardSummary(
          title: StatCardType.daysRemaining.title,
          value: '$remaining',
          subtitle: 'до конца периода',
        );
      case StatCardType.note:
        return _StatCardSummary(
          title: StatCardType.note.title,
          value: card.noteText.isEmpty ? 'Нажмите, чтобы добавить текст' : card.noteText,
          subtitle: '',
        );
    }
  }

  int _calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return 0;
    }

    var streak = 1;
    for (var index = completedDates.length - 1; index > 0; index--) {
      final current = completedDates[index];
      final previous = completedDates[index - 1];
      if (current.difference(previous).inDays == 1) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  int _completedCountForCurrentPeriod() {
    final now = dayOnly(DateTime.now());
    final range = _rangeForPeriod(now);

    return completions.where((item) {
      if (!item.isCompleted) {
        return false;
      }

      final date = dayOnly(item.date);
      return !date.isBefore(range.$1) && !date.isAfter(range.$2);
    }).length;
  }

  int _daysRemainingInPeriod() {
    final now = dayOnly(DateTime.now());
    final end = _rangeForPeriod(now).$2;
    return math.max(end.difference(now).inDays, 0);
  }

  (DateTime, DateTime) _rangeForPeriod(DateTime anchor) {
    switch (habit.targetPeriod) {
      case HabitGoalPeriod.week:
        final monday = anchor.subtract(Duration(days: anchor.weekday - DateTime.monday));
        return (monday, monday.add(const Duration(days: 6)));
      case HabitGoalPeriod.month:
        return (DateTime(anchor.year, anchor.month, 1), DateTime(anchor.year, anchor.month + 1, 0));
      case HabitGoalPeriod.year:
        return (DateTime(anchor.year, 1, 1), DateTime(anchor.year, 12, 31));
    }
  }

  String _pluralizeDays(int count) {
    final remainder10 = count % 10;
    final remainder100 = count % 100;

    if (remainder10 == 1 && remainder100 != 11) {
      return 'день';
    }
    if (remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 12 || remainder100 > 14)) {
      return 'дня';
    }
    return 'дней';
  }
}

class _StatCardSummary {
  const _StatCardSummary({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;
}

const _availableTypes = <StatCardType>[
  StatCardType.streak,
  StatCardType.progressPercent,
  StatCardType.daysCompleted,
  StatCardType.daysRemaining,
  StatCardType.note,
];
