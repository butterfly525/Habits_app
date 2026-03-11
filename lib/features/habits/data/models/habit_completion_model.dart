import '../../domain/entities/habit_completion.dart';

class HabitCompletionModel {
  const HabitCompletionModel({
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

  HabitCompletion toEntity() {
    return HabitCompletion(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
  }

  factory HabitCompletionModel.fromMap(Map<String, Object?> map) {
    return HabitCompletionModel(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
