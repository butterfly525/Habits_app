import 'package:sqflite/sqflite.dart';

import '../../../../../core/date_only.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/stat_card.dart';
import '../../models/habit_completion_model.dart';
import '../../models/habit_model.dart';
import '../../models/stat_card_model.dart';
import 'local_database.dart';

class HabitsLocalDataSource {
  HabitsLocalDataSource(this._databaseProvider);

  final LocalDatabase _databaseProvider;

  Future<Database> get _db async => _databaseProvider.database;

  Future<List<HabitModel>> getHabits() async {
    final db = await _db;
    final rows = await db.query('habits', orderBy: 'created_at ASC');
    return rows.map(HabitModel.fromMap).toList();
  }

  Future<HabitModel> addHabit({
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('habits', {
      'title': title,
      'color_value': colorValue,
      'target_count': targetCount,
      'target_period': targetPeriod.dbValue,
      'created_at': now,
      'updated_at': now,
    });

    return HabitModel(
      id: id,
      title: title,
      colorValue: colorValue,
      targetCount: targetCount,
      targetPeriod: targetPeriod,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  Future<void> updateHabit({
    required int habitId,
    required String title,
    required int colorValue,
    required int targetCount,
    required HabitGoalPeriod targetPeriod,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'habits',
      {
        'title': title,
        'color_value': colorValue,
        'target_count': targetCount,
        'target_period': targetPeriod.dbValue,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<List<HabitCompletionModel>> getHabitCompletionsInRange({
    required int habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [habitId, toDateKey(from), toDateKey(to)],
      orderBy: 'date ASC',
    );

    return rows.map(HabitCompletionModel.fromMap).toList();
  }

  Future<List<HabitCompletionModel>> getHabitCompletions(int habitId) async {
    final db = await _db;
    final rows = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );

    return rows.map(HabitCompletionModel.fromMap).toList();
  }

  Future<void> toggleCompletion({
    required int habitId,
    required DateTime date,
  }) async {
    final db = await _db;
    final key = toDateKey(date);
    final now = DateTime.now().toIso8601String();

    final rows = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, key],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert('habit_completions', {
        'habit_id': habitId,
        'date': key,
        'is_completed': 1,
        'updated_at': now,
      });
      return;
    }

    final existing = HabitCompletionModel.fromMap(rows.first);
    final nextValue = existing.isCompleted ? 0 : 1;

    await db.update(
      'habit_completions',
      {
        'is_completed': nextValue,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [existing.id],
    );
  }

  Future<List<StatCardModel>> getStatCards(int habitId) async {
    final db = await _db;
    final rows = await db.query(
      'stat_cards',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'position ASC',
    );

    return rows.map(StatCardModel.fromMap).toList();
  }

  Future<StatCardModel?> addStatCard(int habitId) async {
    final db = await _db;
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM stat_cards WHERE habit_id = ?',
      [habitId],
    );
    final count = (countResult.first['count'] as int?) ?? 0;

    if (count >= 20) {
      return null;
    }

    final now = DateTime.now().toIso8601String();
    final id = await db.insert('stat_cards', {
      'habit_id': habitId,
      'position': count,
      'type': StatCardType.empty.dbValue,
      'note_text': '',
      'created_at': now,
      'updated_at': now,
    });

    return StatCardModel(
      id: id,
      habitId: habitId,
      position: count,
      type: StatCardType.empty,
      noteText: '',
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  Future<void> updateStatCard({
    required int cardId,
    required StatCardType type,
    String? noteText,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'stat_cards',
      {
        'type': type.dbValue,
        'note_text': noteText ?? '',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<void> removeLastStatCard(int habitId) async {
    final db = await _db;
    final rows = await db.query(
      'stat_cards',
      columns: ['id'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'position DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return;
    }

    final id = rows.first['id'] as int;
    await db.delete('stat_cards', where: 'id = ?', whereArgs: [id]);
  }
}
