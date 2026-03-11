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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final key = toDateKey(day);
        final isDone = completedDates.contains(key);

        return GestureDetector(
          onTap: () => onToggle(day),
          child: Container(
            width: 40,
            height: 52,
            decoration: BoxDecoration(
              color: isDone ? accentColor.withValues(alpha: 0.85) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDone ? accentColor : Colors.grey.shade400,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.E().format(day),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.d().format(day),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}
