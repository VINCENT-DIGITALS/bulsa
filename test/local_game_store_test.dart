import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/rules/event_selector.dart';
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

  test('persists onboarding completion locally', () async {
    expect(await store.loadOnboardingComplete(), isFalse);

    await store.saveOnboardingComplete();

    expect(await store.loadOnboardingComplete(), isTrue);
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

  test(
    'charges a fixed bill and writes it to the ledger on its due day',
    () async {
      await store.saveRunStartDate(DateTime(2026, 9, 13));
      await store.loadOrCreatePayCycleRun();
      const noSpend = GameChoice(
        label: 'No spend',
        amount: 0,
        category: 'Test',
        description: 'Test choice',
      );
      await store.applyChoice(noSpend);
      await store.applyChoice(noSpend);
      final updated = await store.applyChoice(noSpend);

      expect(updated.cash, 4701);
      expect(
        (await store.loadLedger()).map((entry) => entry.description),
        contains('Mobile data paid'),
      );
    },
  );

  test('moves money to and from savings with ledger entries', () async {
    await store.loadOrCreatePayCycleRun();
    await store.moveCashToSavings(500);
    final updated = await store.withdrawSavings(200);

    expect(updated.cash, 4700);
    expect(updated.savings, 300);
    expect((await store.loadLedger()).map((entry) => entry.amount), [
      -500,
      200,
    ]);
  });

  test('closes a run that crosses its configured debt limit', () async {
    await store.loadOrCreatePayCycleRun();
    final updated = await store.applyChoice(
      const GameChoice(
        label: 'Emergency',
        amount: -6001,
        category: 'Test',
        description: 'Emergency cost',
      ),
    );

    expect(updated.failed, isTrue);
    expect(updated.isClosed, isTrue);
  });

  test(
    'a sound choice route can survive a full cycle and reconcile with its ledger',
    () async {
      await store.saveRunStartDate(DateTime(2026, 9, 1));
      final run = await store.loadOrCreatePayCycleRun();
      GameRun updated = run;

      while (!updated.isClosed) {
        final event = eventForProfileDay(
          day: updated.currentDay,
          profile: const PlayerProfile.empty(),
          seed: updated.eventSeed,
        );
        final soundChoice = event.choices.reduce(
          (best, choice) => choice.amount > best.amount ? choice : best,
        );
        updated = await store.applyChoice(soundChoice);
      }

      final ledger = await store.loadLedger();
      final ledgerTotal = ledger.fold<int>(
        0,
        (total, entry) => total + entry.amount,
      );
      expect(updated.completed, isTrue);
      expect(updated.failed, isFalse);
      expect(updated.cash, greaterThanOrEqualTo(0));
      expect(updated.cash - run.cash, ledgerTotal);
    },
  );
}
