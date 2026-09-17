import 'package:bulsa/game/models/game_models.dart';

const fixedBills = <FixedBill>[
  FixedBill(day: 3, title: 'Mobile data', amount: 299),
  FixedBill(day: 6, title: 'Utilities share', amount: 750),
];

List<FixedBill> billsDueOn(int day) =>
    fixedBills.where((bill) => bill.day == day).toList();

/// Returns only bills that can still occur in the active pay cycle.
///
/// A cycle can finish before every default bill day (for example, a short
/// cycle ending on game day 2), so the Today screen must not forecast bills
/// that will never be charged in that run.
List<FixedBill> upcomingBillsForCycle({
  required int currentDay,
  required int totalDays,
}) => fixedBills
    .where((bill) => bill.day >= currentDay && bill.day <= totalDays)
    .toList();
