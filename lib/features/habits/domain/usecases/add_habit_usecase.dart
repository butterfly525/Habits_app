import '../entities/habit.dart';
import '../repositories/habits_repository.dart';

class AddHabitUseCase {
  const AddHabitUseCase(this._repository);

  final HabitsRepository _repository;

  Future<Habit> call({
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) {
    return _repository.addHabit(
      title: title,
      colorValue: colorValue,
      targetCount: targetCount,
      targetPeriod: targetPeriod,
    );
  }
}
