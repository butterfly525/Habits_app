import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/date_only.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.completedDates,
    required this.accentColor,
    required this.onToggle,
  });

  final DateTime month;
  final Set<String> completedDates;
  final Color accentColor;
  final ValueChanged<DateTime> onToggle;

  @override
  Widget build(BuildContext context) {
    final days = _daysForGrid(month);
    final today = dayOnly(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Пн'),
            Text('Вт'),
            Text('Ср'),
            Text('Чт'),
            Text('Пт'),
            Text('Сб'),
            Text('Вс'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return const SizedBox.shrink();
            }

            final key = toDateKey(day);
            final inCurrentMonth = day.month == month.month;
            final isDone = completedDates.contains(key);
            final isToday = dayOnly(day) == today;
            final isFuture = dayOnly(day).isAfter(today);

            return GestureDetector(
              onTap: isFuture ? null : () => onToggle(day),
              child: Opacity(
                opacity: isFuture ? 0.45 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: !inCurrentMonth
                        ? scheme.surface.withValues(alpha: isDark ? 0.32 : 0.72)
                        : isDone
                            ? accentColor.withValues(alpha: 0.85)
                            : scheme.surface.withValues(alpha: isDark ? 0.62 : 0.88),
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: isToday ? 2 : 1,
                      color: isToday
                          ? scheme.primary
                          : isDone
                              ? accentColor
                              : scheme.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat.d().format(day),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: inCurrentMonth
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.46),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<DateTime?> _daysForGrid(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final leading = start.weekday - DateTime.monday;
    final totalDays = end.day;

    final items = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      items.add(null);
    }

    for (var day = 1; day <= totalDays; day++) {
      items.add(DateTime(month.year, month.month, day));
    }

    while (items.length % 7 != 0) {
      items.add(null);
    }

    return items;
  }
}
