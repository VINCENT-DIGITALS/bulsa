import 'package:bulsa/game/models/game_models.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class LocalGameStore {
  LocalGameStore(this._database);

  factory LocalGameStore.open() {
    return LocalGameStore(driftDatabase(name: 'bulsa'));
  }

  final DatabaseConnection _database;

  Future<void> initialize() async {
    await _database.ensureOpen(const _StoreExecutorUser());
    await _database.runCustom('''
      CREATE TABLE IF NOT EXISTS game_runs (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        current_day INTEGER NOT NULL,
        total_days INTEGER NOT NULL,
        cash INTEGER NOT NULL,
        savings INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await _database.runCustom('''
      CREATE TABLE IF NOT EXISTS ledger_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }

  Future<GameRun> loadOrCreateDemoRun() async {
    final existing = await _loadRun();
    if (existing != null) {
      return existing;
    }

    await _database.runInsert(
      'INSERT INTO game_runs (id, current_day, total_days, cash, savings, completed) VALUES (1, 1, 7, 5000, 0, 0)',
      const [],
    );
    return _loadRunOrThrow();
  }

  Future<GameRun> applyChoice(GameChoice choice) async {
    final run = await _loadRunOrThrow();
    if (run.completed) {
      throw StateError('This pay cycle is already complete.');
    }

    await _database.runInsert(
      'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
      [run.currentDay, choice.amount, choice.category, choice.description],
    );

    final nextDay = run.currentDay + 1;
    final completed = nextDay > run.totalDays;
    await _database.runUpdate(
      'UPDATE game_runs SET cash = ?, current_day = ?, completed = ? WHERE id = 1',
      [run.cash + choice.amount, nextDay, completed ? 1 : 0],
    );
    return _loadRunOrThrow();
  }

  Future<List<LedgerEntry>> loadLedger() async {
    final rows = await _database.runSelect(
      'SELECT day, amount, category, description FROM ledger_entries ORDER BY id ASC',
      const [],
    );
    return rows
        .map(
          (row) => LedgerEntry(
            day: row['day']! as int,
            amount: row['amount']! as int,
            category: row['category']! as String,
            description: row['description']! as String,
          ),
        )
        .toList();
  }

  Future<void> resetDemoRun() async {
    await _database.runDelete('DELETE FROM ledger_entries', const []);
    await _database.runDelete('DELETE FROM game_runs', const []);
  }

  Future<GameRun?> _loadRun() async {
    final rows = await _database.runSelect(
      'SELECT * FROM game_runs WHERE id = 1',
      const [],
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    return GameRun(
      currentDay: row['current_day']! as int,
      totalDays: row['total_days']! as int,
      cash: row['cash']! as int,
      savings: row['savings']! as int,
      completed: (row['completed']! as int) == 1,
    );
  }

  Future<GameRun> _loadRunOrThrow() async {
    final run = await _loadRun();
    if (run == null) {
      throw StateError('No active game run exists.');
    }
    return run;
  }
}

class _StoreExecutorUser implements QueryExecutorUser {
  const _StoreExecutorUser();

  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
