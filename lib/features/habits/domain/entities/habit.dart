enum HabitGoalPeriod { week, month, year }

extension HabitGoalPeriodX on HabitGoalPeriod {
  String get dbValue {
    switch (this) {
      case HabitGoalPeriod.week:
        return 'week';
      case HabitGoalPeriod.month:
        return 'month';
      case HabitGoalPeriod.year:
        return 'year';
    }
  }

  String get label {
    switch (this) {
      case HabitGoalPeriod.week:
        return 'в неделю';
      case HabitGoalPeriod.month:
        return 'в месяц';
      case HabitGoalPeriod.year:
        return 'в год';
    }
  }

  static HabitGoalPeriod fromDbValue(String value) {
    switch (value) {
      case 'month':
        return HabitGoalPeriod.month;
      case 'year':
        return HabitGoalPeriod.year;
      case 'week':
      default:
        return HabitGoalPeriod.week;
    }
  }
}

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.targetCount,
    required this.targetPeriod,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final int colorValue;
  final int targetCount;
  final HabitGoalPeriod targetPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;
}
