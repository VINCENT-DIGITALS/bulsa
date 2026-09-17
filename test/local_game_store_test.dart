import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
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

  test('creates one persistent demo run', () async {
    final created = await store.loadOrCreateDemoRun();
    final reloaded = await store.loadOrCreateDemoRun();

    expect(created.currentDay, 1);
    expect(created.totalDays, 7);
    expect(created.cash, 5000);
    expect(reloaded.cash, created.cash);
  });

  test('records a choice and updates the run', () async {
    await store.loadOrCreateDemoRun();
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

  test('finishes after the final daily choice', () async {
    await store.loadOrCreateDemoRun();
    const noSpend = GameChoice(
      label: 'No spend',
      amount: 0,
      category: 'Test',
      description: 'Test choice',
    );

    GameRun updated = await store.loadOrCreateDemoRun();
    for (var day = 0; day < 7; day++) {
      updated = await store.applyChoice(noSpend);
    }

    expect(updated.completed, isTrue);
    expect(updated.daysRemaining, 0);
  });
}
