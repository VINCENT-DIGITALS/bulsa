import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const keepDate = PaySchedule(
    rules: [PaydayRule.fifteenth, PaydayRule.monthEnd],
    weekendPolicy: WeekendPaydayPolicy.keepDate,
  );

  test('uses the actual month end in February', () {
    expect(
      keepDate.paydaysForMonth(2025, 2).last.scheduledDate,
      DateTime(2025, 2, 28),
    );
    expect(
      keepDate.paydaysForMonth(2024, 2).last.scheduledDate,
      DateTime(2024, 2, 29),
    );
  });

  test('moves a Saturday month-end payday to Friday when selected', () {
    const schedule = PaySchedule(
      rules: [PaydayRule.monthEnd],
      weekendPolicy: WeekendPaydayPolicy.previousFriday,
    );
    final payday = schedule.paydaysForMonth(2026, 10).single;

    expect(payday.scheduledDate, DateTime(2026, 10, 31));
    expect(payday.payDate, DateTime(2026, 10, 30));
  });

  test('moves a Sunday payday to Monday when selected', () {
    const schedule = PaySchedule(
      rules: [PaydayRule.fifteenth],
      weekendPolicy: WeekendPaydayPolicy.nextMonday,
    );
    final payday = schedule.paydaysForMonth(2026, 2).single;

    expect(payday.scheduledDate, DateTime(2026, 2, 15));
    expect(payday.payDate, DateTime(2026, 2, 16));
  });

  test('finds the next adjusted payday across a month boundary', () {
    const schedule = PaySchedule(
      rules: [PaydayRule.fifteenth, PaydayRule.monthEnd],
      weekendPolicy: WeekendPaydayPolicy.previousFriday,
    );

    final next = schedule.nextPaydayAfter(DateTime(2026, 10, 31));

    expect(next.rule, PaydayRule.fifteenth);
    expect(next.payDate, DateTime(2026, 11, 13));
  });
}
