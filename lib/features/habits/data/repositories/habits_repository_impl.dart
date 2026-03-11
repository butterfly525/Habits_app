import '../../../../core/date_only.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/entities/habit_details_view.dart';
import '../../domain/entities/habit_week_view.dart';
import '../../domain/entities/stat_card.dart';
import '../../domain/repositories/habits_repository.dart';
import '../datasources/local/habits_local_data_source.dart';
import '../datasources/remote/habits_remote_data_source.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl({
    required HabitsLocalDataSource local,
    required HabitsRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final HabitsLocalDataSource _local;
  final HabitsRemoteDataSource _remote;

  @override
  Future<Habit> addHabit({
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    final created = await _local.addHabit(
      title: title.trim(),
      colorValue: colorValue,
      targetCount: targetCount,
      targetPeriod: targetPeriod,
    );
    await _remote.pushDirtyChanges();
    return created.toEntity();
  }

  @override
  Future<void> updateHabit({
    required int habitId,
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    await _local.updateHabit(
      habitId: habitId,
      title: title.trim(),
      colorValue: colorValue,
      targetCount: targetCount,
      targetPeriod: targetPeriod,
    );
    await _remote.pushDirtyChanges();
  }

  @override
  Future<void> deleteHabit(int habitId) async {
    await _local.deleteHabit(habitId);
    await _remote.pushDirtyChanges();
  }

  @override
  Future<HabitDetailsView> getHabitDetails({
    required int habitId,
    required DateTime month,
  }) async {
    final habits = await getHabits();
    final habit = habits.firstWhere((item) => item.id == habitId);
    final completions = await getCompletionsForHabitMonth(
      habitId: habitId,
      month: month,
    );
    final allCompletions = await _local.getHabitCompletions(habitId);
    final statCards = await getStatCards(habitId);

    return HabitDetailsView(
      habit: habit,
      completions: completions,
      allCompletions: allCompletions.map((item) => item.toEntity()).toList(),
      statCards: statCards,
    );
  }

  @override
  Future<List<Habit>> getHabits() async {
    final models = await _local.getHabits();
    return models.map((item) => item.toEntity()).toList();
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabitMonth({
    required int habitId,
    required DateTime month,
  }) async {
    final models = await _local.getHabitCompletionsInRange(
      habitId: habitId,
      from: monthStart(month),
      to: monthEnd(month),
    );

    return models.map((item) => item.toEntity()).toList();
  }

  @override
  Future<List<HabitWeekView>> getHabitsForWeek(DateTime anchorDate) async {
    final habits = await getHabits();
    final weekDays = _weekDaysFor(anchorDate);
    final from = weekDays.first;
    final to = weekDays.last;

    final result = <HabitWeekView>[];
    for (final habit in habits) {
      final completions = await _local.getHabitCompletionsInRange(
        habitId: habit.id,
        from: from,
        to: to,
      );

      final completedDates = completions
          .where((item) => item.isCompleted)
          .map((item) => toDateKey(item.date))
          .toSet();
      final periodRange = _rangeForGoalPeriod(
        anchorDate: anchorDate,
        period: habit.targetPeriod,
      );
      final targetCompletions = await _local.getHabitCompletionsInRange(
        habitId: habit.id,
        from: periodRange.$1,
        to: periodRange.$2,
      );
      final currentPeriodCompletedCount =
          targetCompletions.where((item) => item.isCompleted).length;

      result.add(
        HabitWeekView(
          habit: habit,
          weekDays: weekDays,
          completedDates: completedDates,
          currentPeriodCompletedCount: currentPeriodCompletedCount,
        ),
      );
    }

    return result;
  }

  @override
  Future<void> toggleCompletion({
    required int habitId,
    required DateTime date,
  }) async {
    await _local.toggleCompletion(habitId: habitId, date: dayOnly(date));
    await _remote.pushDirtyChanges();
  }

  @override
  Future<List<StatCard>> getStatCards(int habitId) async {
    final models = await _local.getStatCards(habitId);
    return models.map((item) => item.toEntity()).toList();
  }

  @override
  Future<StatCard?> addStatCard(int habitId) async {
    final created = await _local.addStatCard(habitId);
    await _remote.pushDirtyChanges();
    return created?.toEntity();
  }

  @override
  Future<void> updateStatCard({
    required int cardId,
    required StatCardType type,
    String? noteText,
  }) async {
    await _local.updateStatCard(
      cardId: cardId,
      type: type,
      noteText: noteText,
    );
    await _remote.pushDirtyChanges();
  }

  @override
  Future<void> removeLastStatCard(int habitId) async {
    await _local.removeLastStatCard(habitId);
    await _remote.pushDirtyChanges();
  }

  List<DateTime> _weekDaysFor(DateTime anchorDate) {
    final date = dayOnly(anchorDate);
    final mondayOffset = date.weekday - DateTime.monday;
    final monday = date.subtract(Duration(days: mondayOffset));

    return List<DateTime>.generate(
      7,
      (index) => monday.add(Duration(days: index)),
      growable: false,
    );
  }

  (DateTime, DateTime) _rangeForGoalPeriod({
    required DateTime anchorDate,
    required HabitGoalPeriod period,
  }) {
    final date = dayOnly(anchorDate);

    switch (period) {
      case HabitGoalPeriod.week:
        final weekDays = _weekDaysFor(date);
        return (weekDays.first, weekDays.last);
      case HabitGoalPeriod.month:
        return (monthStart(date), monthEnd(date));
      case HabitGoalPeriod.year:
        return (DateTime(date.year, 1, 1), DateTime(date.year, 12, 31));
    }
  }
}
