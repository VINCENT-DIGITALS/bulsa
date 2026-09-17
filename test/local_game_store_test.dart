import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DatabaseConnection database;
  late LocalGameStore store;

  setUp(() async {
    database = DatabaseConnection(NativeDatabase.memory());
    store = LocalGameStore(database);
    await store.initialize();
  });

  tearDown(() => database.close());

  test(
    'creates one persistent run that ends on the configured payday',
    () async {
      await store.saveRunStartDate(DateTime(2026, 9, 14));
      final created = await store.loadOrCreatePayCycleRun();
      final reloaded = await store.loadOrCreatePayCycleRun();

      expect(created.currentDay, 1);
      expect(created.totalDays, 2);
      expect(created.startDate, DateTime(2026, 9, 14));
      expect(created.paydayDate, DateTime(2026, 9, 15));
      expect(created.cash, 5000);
      expect(reloaded.cash, created.cash);
    },
  );

  test('records a choice and updates the run', () async {
    await store.saveRunStartDate(DateTime(2026, 9, 14));
    await store.loadOrCreatePayCycleRun();
    final updated = await store.applyChoice(
      const GameChoice(
        label: 'Carinderia — ₱120',
        amount: -120,
        category: 'Food',
        description: 'Carinderia lunch',
      ),
    );

    final ledger = await store.loadLedger();
    expect(updated.currentDay, 2);
    expect(updated.cash, 4880);
    expect(ledger, hasLength(1));
    expect(ledger.single.amount, -120);
    expect(ledger.single.category, 'Food');
  });

  test('adds configured confirmed income when payday is reached', () async {
    await store.saveRunStartDate(DateTime(2026, 9, 14));
    await store.saveConfirmedSalary(10000);
    await store.saveRecurringAllowance(500);
    await store.loadOrCreatePayCycleRun();
    const noSpend = GameChoice(
      label: 'No spend',
      amount: 0,
      category: 'Test',
      description: 'Test choice',
    );

    GameRun updated = await store.loadOrCreatePayCycleRun();
    for (var day = 0; day < 2; day++) {
      updated = await store.applyChoice(noSpend);
    }

    expect(updated.completed, isTrue);
    expect(updated.daysRemaining, 0);
    expect(updated.cash, 15500);
    final ledger = await store.loadLedger();
    expect(
      ledger.map((entry) => entry.description),
      contains('Confirmed salary'),
    );
    expect(
      ledger.map((entry) => entry.description),
      contains('Recurring allowance'),
    );
  });

  test('persists the selected weekend payday policy', () async {
    expect(
      await store.loadWeekendPaydayPolicy(),
      WeekendPaydayPolicy.previousFriday,
    );

    await store.saveWeekendPaydayPolicy(WeekendPaydayPolicy.nextMonday);

    expect(
      await store.loadWeekendPaydayPolicy(),
      WeekendPaydayPolicy.nextMonday,
    );
  });

  test('persists the selected run start date', () async {
    final date = DateTime(2026, 9, 15);
    await store.saveRunStartDate(date);

    expect(await store.loadRunStartDate(), date);
  });

  test('persists confirmed salary and recurring allowance', () async {
    await store.saveConfirmedSalary(12000);
    await store.saveRecurringAllowance(750);

    expect(await store.loadConfirmedSalary(), 12000);
    expect(await store.loadRecurringAllowance(), 750);
  });

  test(
    'persists an optional local profile without changing payday income',
    () async {
      const profile = PlayerProfile(
        displayName: 'Vin',
        jobTitle: 'Mobile app developer',
        jobDescription: 'Builds client apps.',
        companyName: 'Digital Studio',
        employmentType: EmploymentType.salaried,
        workTags: {'Remote work'},
        avatar: ProfileAvatar.triangle,
      );
      await store.saveConfirmedSalary(15000);
      await store.saveProfile(profile);

      final loaded = await store.loadProfile();
      expect(loaded.displayName, 'Vin');
      expect(loaded.workTags, {'Remote work'});
      expect(loaded.avatar, ProfileAvatar.triangle);
      expect(await store.loadConfirmedSalary(), 15000);
    },
  );
}
