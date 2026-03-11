import '../entities/habit.dart';
import '../entities/habit_completion.dart';
import '../entities/habit_details_view.dart';
import '../entities/habit_week_view.dart';
import '../entities/stat_card.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getHabits();
  Future<Habit> addHabit({
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  });
  Future<void> updateHabit({
    required int habitId,
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  });
  Future<List<HabitWeekView>> getHabitsForWeek(DateTime anchorDate);

  Future<List<HabitCompletion>> getCompletionsForHabitMonth({
    required int habitId,
    required DateTime month,
  });

  Future<void> toggleCompletion({
    required int habitId,
    required DateTime date,
  });

  Future<HabitDetailsView> getHabitDetails({
    required int habitId,
    required DateTime month,
  });

  Future<List<StatCard>> getStatCards(int habitId);
  Future<StatCard?> addStatCard(int habitId);
  Future<void> updateStatCard({
    required int cardId,
    required StatCardType type,
    String? noteText,
  });
  Future<void> removeLastStatCard(int habitId);
}
