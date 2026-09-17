import 'dart:convert';

import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:bulsa/game/rules/fixed_bills.dart';
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
    await _database.runCustom('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await _ensureGameRunColumn('start_date', 'TEXT');
    await _ensureGameRunColumn('payday_date', 'TEXT');
    await _ensureGameRunColumn(
      'confirmed_salary',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureGameRunColumn('debt_limit', 'INTEGER NOT NULL DEFAULT -1000');
    await _ensureGameRunColumn('failed', 'INTEGER NOT NULL DEFAULT 0');
    await _ensureGameRunColumn('event_seed', 'INTEGER NOT NULL DEFAULT 0');
    await _ensureGameRunColumn(
      'recurring_allowance',
      'INTEGER NOT NULL DEFAULT 0',
    );
  }

  Future<void> _ensureGameRunColumn(String name, String definition) async {
    final columns = await _database.runSelect(
      'PRAGMA table_info(game_runs)',
      const [],
    );
    final exists = columns.any((column) => column['name'] == name);
    if (!exists) {
      await _database.runCustom(
        'ALTER TABLE game_runs ADD COLUMN $name $definition',
      );
    }
  }

  Future<WeekendPaydayPolicy> loadWeekendPaydayPolicy() async {
    final rows = await _database.runSelect(
      'SELECT value FROM app_settings WHERE key = ?',
      const ['weekend_payday_policy'],
    );
    if (rows.isEmpty) return WeekendPaydayPolicy.previousFriday;
    return WeekendPaydayPolicy.values.byName(rows.single['value']! as String);
  }

  Future<void> saveWeekendPaydayPolicy(WeekendPaydayPolicy policy) {
    return _database.runCustom(
      'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
      ['weekend_payday_policy', policy.name],
    );
  }

  Future<DateTime> loadRunStartDate() async {
    final rows = await _database.runSelect(
      'SELECT value FROM app_settings WHERE key = ?',
      const ['run_start_date'],
    );
    return rows.isEmpty
        ? DateTime.now()
        : DateTime.parse(rows.single['value']! as String);
  }

  Future<void> saveRunStartDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _database.runCustom(
      'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
      ['run_start_date', normalized.toIso8601String()],
    );
  }

  Future<int> loadConfirmedSalary() => _loadAmountSetting('confirmed_salary');

  Future<void> saveConfirmedSalary(int amount) =>
      _saveAmountSetting('confirmed_salary', amount);

  Future<int> loadRecurringAllowance() =>
      _loadAmountSetting('recurring_allowance');

  Future<void> saveRecurringAllowance(int amount) =>
      _saveAmountSetting('recurring_allowance', amount);

  Future<int> _loadAmountSetting(String key) async {
    final rows = await _database.runSelect(
      'SELECT value FROM app_settings WHERE key = ?',
      [key],
    );
    return rows.isEmpty ? 0 : int.parse(rows.single['value']! as String);
  }

  Future<void> _saveAmountSetting(String key, int amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'must not be negative');
    }
    return _database.runCustom(
      'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
      [key, '$amount'],
    );
  }

  Future<PlayerProfile> loadProfile() async {
    final rows = await _database.runSelect(
      'SELECT value FROM app_settings WHERE key = ?',
      const ['player_profile'],
    );
    if (rows.isEmpty) return const PlayerProfile.empty();
    final json =
        jsonDecode(rows.single['value']! as String) as Map<String, dynamic>;
    return PlayerProfile(
      displayName: json['displayName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      jobDescription: json['jobDescription'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      employmentType: EmploymentType.values.byName(
        json['employmentType'] as String? ?? EmploymentType.salaried.name,
      ),
      workTags: Set<String>.from(
        json['workTags'] as List<dynamic>? ?? const [],
      ),
      avatar: ProfileAvatar.values.byName(
        json['avatar'] as String? ?? ProfileAvatar.circle.name,
      ),
    );
  }

  Future<void> saveProfile(PlayerProfile profile) {
    final encoded = jsonEncode({
      'displayName': profile.displayName.trim(),
      'jobTitle': profile.jobTitle.trim(),
      'jobDescription': profile.jobDescription.trim(),
      'companyName': profile.companyName.trim(),
      'employmentType': profile.employmentType.name,
      'workTags': profile.workTags.toList()..sort(),
      'avatar': profile.avatar.name,
    });
    return _database.runCustom(
      'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
      ['player_profile', encoded],
    );
  }

  Future<GameRun> loadOrCreatePayCycleRun() async {
    final existing = await _loadRun();
    if (existing != null) {
      return existing;
    }

    final startDate = await loadRunStartDate();
    final schedule = PaySchedule(
      rules: const [PaydayRule.fifteenth, PaydayRule.monthEnd],
      weekendPolicy: await loadWeekendPaydayPolicy(),
    );
    final payday = schedule.nextPaydayAfter(startDate).payDate;
    final totalDays = payday.difference(startDate).inDays + 1;
    final salary = await loadConfirmedSalary();
    final allowance = await loadRecurringAllowance();
    await _database.runInsert(
      '''INSERT INTO game_runs
        (id, current_day, total_days, start_date, payday_date, cash, savings,
         confirmed_salary, recurring_allowance, debt_limit, event_seed, completed, failed)
        VALUES (1, 1, ?, ?, ?, 5000, 0, ?, ?, -1000, ?, 0, 0)''',
      [
        totalDays,
        startDate.toIso8601String(),
        payday.toIso8601String(),
        salary,
        allowance,
        startDate.millisecondsSinceEpoch.remainder(100000),
      ],
    );
    return _loadRunOrThrow();
  }

  Future<GameRun?> loadPayCycleRun() => _loadRun();

  Future<GameRun> applyChoice(GameChoice choice) async {
    final run = await _loadRunOrThrow();
    if (run.isClosed) {
      throw StateError('This pay cycle is already closed.');
    }

    final nextDay = run.currentDay + 1;
    final completed = nextDay > run.totalDays;
    final paydayIncome = completed
        ? run.confirmedSalary + run.recurringAllowance
        : 0;
    final dueBills = billsDueOn(run.currentDay);
    final billTotal = dueBills.fold(0, (total, bill) => total + bill.amount);
    final resultingCash = run.cash + choice.amount + paydayIncome - billTotal;
    final failed = resultingCash < run.debtLimit;
    final transaction = _database.beginTransaction();
    try {
      await transaction.ensureOpen(const _StoreExecutorUser());
      await transaction.runInsert(
        'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
        [run.currentDay, choice.amount, choice.category, choice.description],
      );
      for (final bill in dueBills) {
        await transaction.runInsert(
          'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
          [run.currentDay, -bill.amount, 'Bills', '${bill.title} paid'],
        );
      }
      if (completed && run.confirmedSalary > 0) {
        await transaction.runInsert(
          'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
          [run.currentDay, run.confirmedSalary, 'Income', 'Confirmed salary'],
        );
      }
      if (completed && run.recurringAllowance > 0) {
        await transaction.runInsert(
          'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
          [
            run.currentDay,
            run.recurringAllowance,
            'Income',
            'Recurring allowance',
          ],
        );
      }
      await transaction.runUpdate(
        'UPDATE game_runs SET cash = ?, current_day = ?, completed = ?, failed = ? WHERE id = 1',
        [resultingCash, nextDay, completed ? 1 : 0, failed ? 1 : 0],
      );
      await transaction.send();
    } catch (_) {
      await transaction.rollback();
      rethrow;
    }
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

  Future<GameRun> moveCashToSavings(int amount) => _moveSavings(amount, true);

  Future<GameRun> withdrawSavings(int amount) => _moveSavings(amount, false);

  Future<GameRun> _moveSavings(int amount, bool toSavings) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount');
    }
    final run = await _loadRunOrThrow();
    final available = toSavings ? run.cash : run.savings;
    if (amount > available) {
      throw StateError('Not enough ${toSavings ? 'cash' : 'savings'}.');
    }
    final cashChange = toSavings ? -amount : amount;
    final savingsChange = toSavings ? amount : -amount;
    final transaction = _database.beginTransaction();
    try {
      await transaction.ensureOpen(const _StoreExecutorUser());
      await transaction.runInsert(
        'INSERT INTO ledger_entries (day, amount, category, description) VALUES (?, ?, ?, ?)',
        [
          run.currentDay,
          cashChange,
          'Savings',
          toSavings ? 'Moved to savings' : 'Withdrew from savings',
        ],
      );
      await transaction.runUpdate(
        'UPDATE game_runs SET cash = ?, savings = ? WHERE id = 1',
        [run.cash + cashChange, run.savings + savingsChange],
      );
      await transaction.send();
    } catch (_) {
      await transaction.rollback();
      rethrow;
    }
    return _loadRunOrThrow();
  }

  Future<void> resetPayCycleRun() async {
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
    final startDate = row['start_date'] as String?;
    final paydayDate = row['payday_date'] as String?;
    final totalDays = row['total_days']! as int;
    final fallbackStartDate = DateTime.now();
    return GameRun(
      currentDay: row['current_day']! as int,
      totalDays: totalDays,
      startDate: startDate == null
          ? fallbackStartDate
          : DateTime.parse(startDate),
      paydayDate: paydayDate == null
          ? fallbackStartDate.add(Duration(days: totalDays - 1))
          : DateTime.parse(paydayDate),
      cash: row['cash']! as int,
      savings: row['savings']! as int,
      confirmedSalary: row['confirmed_salary']! as int,
      recurringAllowance: row['recurring_allowance']! as int,
      debtLimit: row['debt_limit']! as int,
      eventSeed: row['event_seed']! as int,
      completed: (row['completed']! as int) == 1,
      failed: (row['failed']! as int) == 1,
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
