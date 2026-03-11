import 'habit.dart';

class HabitWeekView {
  const HabitWeekView({
    required this.habit,
    required this.weekDays,
    required this.completedDates,
    required this.currentPeriodCompletedCount,
  });

  final Habit habit;
  final List<DateTime> weekDays;
  final Set<String> completedDates;
  final int currentPeriodCompletedCount;
}
