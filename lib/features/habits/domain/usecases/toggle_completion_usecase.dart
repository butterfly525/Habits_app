import '../repositories/habits_repository.dart';

class ToggleCompletionUseCase {
  const ToggleCompletionUseCase(this._repository);

  final HabitsRepository _repository;

  Future<void> call({
    required int habitId,
    required DateTime date,
  }) {
    return _repository.toggleCompletion(habitId: habitId, date: date);
  }
}
