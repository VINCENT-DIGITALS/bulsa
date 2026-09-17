import 'package:bulsa/game/models/game_models.dart';

const fixedBills = <FixedBill>[
  FixedBill(day: 3, title: 'Mobile data', amount: 299),
  FixedBill(day: 6, title: 'Utilities share', amount: 750),
];

List<FixedBill> billsDueOn(int day) =>
    fixedBills.where((bill) => bill.day == day).toList();
