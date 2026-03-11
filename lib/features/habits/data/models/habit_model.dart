import '../../domain/entities/habit.dart';

class HabitModel {
  const HabitModel({
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

  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      colorValue: colorValue,
      targetCount: targetCount,
      targetPeriod: targetPeriod,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory HabitModel.fromMap(Map<String, Object?> map) {
    return HabitModel(
      id: map['id'] as int,
      title: map['title'] as String,
      colorValue: map['color_value'] as int,
      targetCount: map['target_count'] as int,
      targetPeriod: HabitGoalPeriodX.fromDbValue(map['target_period'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
