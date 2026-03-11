class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
    required this.updatedAt,
  });

  final int id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;
  final DateTime updatedAt;
}
