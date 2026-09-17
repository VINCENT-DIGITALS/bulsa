import 'package:bulsa/game/rules/fixed_bills.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('excludes bills after a short pay cycle ends', () {
    expect(upcomingBillsForCycle(currentDay: 1, totalDays: 2), isEmpty);
  });

  test('includes only remaining bills within the active cycle', () {
    expect(
      upcomingBillsForCycle(
        currentDay: 4,
        totalDays: 6,
      ).map((bill) => bill.title),
      ['Utilities share'],
    );
  });
}
