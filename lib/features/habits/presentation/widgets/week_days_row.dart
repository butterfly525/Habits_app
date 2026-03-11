import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/date_only.dart';

class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({
    super.key,
    required this.days,
    required this.completedDates,
    required this.accentColor,
    required this.onToggle,
  });

  final List<DateTime> days;
  final Set<String> completedDates;
  final Color accentColor;
  final ValueChanged<DateTime> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final itemWidth = (constraints.maxWidth - spacing * (days.length - 1)) / days.length;

        return Row(
          children: [
            for (var index = 0; index < days.length; index++) ...[
              if (index > 0) const SizedBox(width: spacing),
              _DayCell(
                day: days[index],
                size: itemWidth,
                completedDates: completedDates,
                accentColor: accentColor,
                onToggle: onToggle,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.size,
    required this.completedDates,
    required this.accentColor,
    required this.onToggle,
  });

  final DateTime day;
  final double size;
  final Set<String> completedDates;
  final Color accentColor;
  final ValueChanged<DateTime> onToggle;

  @override
  Widget build(BuildContext context) {
    final key = toDateKey(day);
    final isDone = completedDates.contains(key);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseBackground = isDarkTheme ? const Color(0xFF1A1330) : Colors.grey.shade200;
    final baseBorder = isDarkTheme ? const Color(0x6630F7FF) : Colors.grey.shade400;
    final textColor = isDone
        ? (accentColor.computeLuminance() > 0.5 ? const Color(0xFF111111) : Colors.white)
        : (isDarkTheme ? const Color(0xFFF3EFFF) : const Color(0xFF24112E));

    return GestureDetector(
      onTap: () => onToggle(day),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDone ? accentColor.withValues(alpha: 0.85) : baseBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone ? accentColor : baseBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.d().format(day),
              style: TextStyle(
                fontSize: size < 28 ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
