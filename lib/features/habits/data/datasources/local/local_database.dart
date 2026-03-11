import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'habits_app.db');

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            color_value INTEGER NOT NULL,
            target_count INTEGER NOT NULL,
            target_period TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE habit_completions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            is_completed INTEGER NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(habit_id, date),
            FOREIGN KEY(habit_id) REFERENCES habits(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE stat_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id INTEGER NOT NULL,
            position INTEGER NOT NULL,
            type TEXT NOT NULL,
            note_text TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(habit_id) REFERENCES habits(id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_completions_habit_date ON habit_completions(habit_id, date)',
        );
        await db.execute(
          'CREATE INDEX idx_stat_cards_habit_position ON stat_cards(habit_id, position)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE habits ADD COLUMN color_value INTEGER NOT NULL DEFAULT 4283215696',
          );
          await db.execute(
            'ALTER TABLE habits ADD COLUMN target_count INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            "ALTER TABLE habits ADD COLUMN target_period TEXT NOT NULL DEFAULT 'week'",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE stat_cards ADD COLUMN type TEXT NOT NULL DEFAULT 'empty'",
          );
          await db.execute(
            "ALTER TABLE stat_cards ADD COLUMN note_text TEXT NOT NULL DEFAULT ''",
          );
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return _database!;
  }
}
