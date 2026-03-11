import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/date_only.dart';
import '../../data/datasources/local/habits_local_data_source.dart';
import '../../data/datasources/local/local_database.dart';
import '../../data/datasources/remote/habits_remote_data_source.dart';
import '../../data/repositories/habits_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_details_view.dart';
import '../../domain/entities/habit_week_view.dart';
import '../../domain/entities/stat_card.dart';
import '../../domain/repositories/habits_repository.dart';

final selectedWeekAnchorProvider = StateProvider<DateTime>((ref) {
  return dayOnly(DateTime.now());
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final refreshTickProvider = StateProvider<int>((ref) => 0);

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

final habitsLocalDataSourceProvider = Provider<HabitsLocalDataSource>((ref) {
  return HabitsLocalDataSource(ref.read(localDatabaseProvider));
});

final habitsRemoteDataSourceProvider = Provider<HabitsRemoteDataSource>((ref) {
  return NoopHabitsRemoteDataSource();
});

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepositoryImpl(
    local: ref.read(habitsLocalDataSourceProvider),
    remote: ref.read(habitsRemoteDataSourceProvider),
  );
});

final habitsWeekProvider = FutureProvider<List<HabitWeekView>>((ref) async {
  ref.watch(refreshTickProvider);
  final anchor = ref.watch(selectedWeekAnchorProvider);
  final repository = ref.read(habitsRepositoryProvider);
  return repository.getHabitsForWeek(anchor);
});

final habitDetailsProvider = FutureProvider.family<
    HabitDetailsView,
    ({int habitId, DateTime month})>((ref, args) async {
  ref.watch(refreshTickProvider);
  final repository = ref.read(habitsRepositoryProvider);
  return repository.getHabitDetails(habitId: args.habitId, month: args.month);
});

class HabitsActions {
  HabitsActions(this._ref);

  final Ref _ref;

  Future<void> addHabit({
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    await _ref.read(habitsRepositoryProvider).addHabit(
          title: title,
          colorValue: colorValue,
          targetCount: targetCount,
          targetPeriod: targetPeriod,
        );
    _invalidate();
  }

  Future<void> updateHabit({
    required int habitId,
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    await _ref.read(habitsRepositoryProvider).updateHabit(
          habitId: habitId,
          title: title,
          colorValue: colorValue,
          targetCount: targetCount,
          targetPeriod: targetPeriod,
        );
    _invalidate();
  }

  Future<void> deleteHabit(int habitId) async {
    await _ref.read(habitsRepositoryProvider).deleteHabit(habitId);
    _invalidate();
  }

  Future<void> toggleCompletion({
    required int habitId,
    required DateTime date,
  }) async {
    await _ref.read(habitsRepositoryProvider).toggleCompletion(
          habitId: habitId,
          date: date,
        );
    _invalidate();
  }

  Future<void> addStatCard(int habitId) async {
    await _ref.read(habitsRepositoryProvider).addStatCard(habitId);
    _invalidate();
  }

  Future<void> updateStatCard({
    required int cardId,
    required StatCardType type,
    String? noteText,
  }) async {
    await _ref.read(habitsRepositoryProvider).updateStatCard(
          cardId: cardId,
          type: type,
          noteText: noteText,
        );
    _invalidate();
  }

  Future<void> removeStatCard(int habitId) async {
    await _ref.read(habitsRepositoryProvider).removeLastStatCard(habitId);
    _invalidate();
  }

  void _invalidate() {
    final tick = _ref.read(refreshTickProvider);
    _ref.read(refreshTickProvider.notifier).state = tick + 1;
  }
}

final habitsActionsProvider = Provider<HabitsActions>((ref) {
  return HabitsActions(ref);
});
