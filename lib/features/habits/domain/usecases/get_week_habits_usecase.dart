import '../entities/habit_week_view.dart';
import '../repositories/habits_repository.dart';

class GetWeekHabitsUseCase {
  const GetWeekHabitsUseCase(this._repository);

  final HabitsRepository _repository;

  Future<List<HabitWeekView>> call(DateTime anchorDate) {
    return _repository.getHabitsForWeek(anchorDate);
  }
}
