import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:bulsa/main.dart';
import 'package:bulsa/screens/calendar_page.dart';
import 'package:bulsa/screens/profile_page.dart';
import 'package:bulsa/screens/today_page.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

  testWidgets('saves an optional local profile from the Profile screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildBulsaTheme(),
        home: Scaffold(body: ProfilePage(store: store)),
      ),
    );
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Vin');
    await tester.enterText(fields.at(1), 'Mobile app developer');
    await tester.scrollUntilVisible(
      find.text('Save profile'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save profile'));
    await tester.pump();

    final profile = await store.loadProfile();
    expect(profile.displayName, 'Vin');
    expect(profile.jobTitle, 'Mobile app developer');
  });

  testWidgets('saves pay schedule settings from the Calendar screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildBulsaTheme(),
        home: Scaffold(body: CalendarPage(store: store)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Delay'));
    await tester.pump();
    expect(
      await store.loadWeekendPaydayPolicy(),
      WeekendPaydayPolicy.nextMonday,
    );

    await tester.tap(find.text('Edit confirmed payday income'));
    await tester.pump();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '15000');
    await tester.enterText(fields.at(1), '1000');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(await store.loadConfirmedSalary(), 15000);
    expect(await store.loadRecurringAllowance(), 1000);
  });

  testWidgets('moves cash to savings and confirms a withdrawal from Today', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await store.saveRunStartDate(DateTime(2026, 9, 14));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildBulsaTheme(),
        home: Scaffold(body: TodayPage(store: store)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    await tester.tap(find.text('Save ₱100'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    var run = await store.loadPayCycleRun();
    expect(run!.cash, 4900);
    expect(run.savings, 100);

    await tester.tap(find.text('Withdraw ₱100'));
    await tester.pump();
    expect(find.text('Withdraw savings?'), findsOneWidget);
    await tester.tap(find.text('Withdraw'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    run = await store.loadPayCycleRun();
    expect(run!.cash, 5000);
    expect(run.savings, 0);
  });

  testWidgets('renders each core tab on a compact phone at 1.3 text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await store.saveOnboardingComplete();
    await store.saveRunStartDate(DateTime(2026, 9, 14));

    await tester.pumpWidget(BulsaApp(store: store));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Calendar'), findsWidgets);

    for (final destination in [
      Icons.today_outlined,
      Icons.receipt_long_outlined,
      Icons.person_outline,
      Icons.calendar_month_outlined,
    ]) {
      await tester.tap(find.byIcon(destination).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(tester.takeException(), equals(null));
    }
  });

  testWidgets('plays and persists a complete configured pay cycle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await store.saveOnboardingComplete();
    await store.saveRunStartDate(DateTime(2026, 9, 14));
    await store.saveConfirmedSalary(10000);

    await tester.pumpWidget(BulsaApp(store: store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.today_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Today: 9/14/2026 · Payday: 9/15/2026'), findsOneWidget);
    expect(find.text('AVAILABLE CASH'), findsOneWidget);
    expect(find.text('SAVINGS'), findsOneWidget);
    expect(find.text('Lunch break'), findsOneWidget);
    final packedSnack = find.widgetWithText(
      OutlinedButton,
      'Packed snack — ₱0',
    );
    await tester.tap(packedSnack);
    await tester.tap(packedSnack);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Rainy commute'), findsOneWidget);
    final jeepney = find.widgetWithText(OutlinedButton, 'Jeepney — ₱15');
    await tester.tap(jeepney);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Pay cycle complete'), findsOneWidget);
    expect(find.text('Start a new pay cycle'), findsOneWidget);

    final reloaded = await store.loadPayCycleRun();
    final ledger = await store.loadLedger();
    expect(reloaded, isNot(equals(null)));
    expect(reloaded!.completed, isTrue);
    expect(reloaded.cash, 14985);
    expect(
      ledger.map((entry) => entry.description),
      containsAll(['Packed snack', 'Jeepney fare', 'Confirmed salary']),
    );
    expect(
      ledger.where((entry) => entry.description == 'Packed snack'),
      hasLength(1),
    );
  });
}
