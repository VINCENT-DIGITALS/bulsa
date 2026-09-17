import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/pay_cycle_result.dart';
import 'package:flutter_test/flutter_test.dart';

GameRun run({int cash = 500, int savings = 0, bool failed = false}) => GameRun(
  currentDay: 2,
  totalDays: 1,
  startDate: DateTime(2026, 9, 14),
  paydayDate: DateTime(2026, 9, 15),
  cash: cash,
  savings: savings,
  confirmedSalary: 0,
  recurringAllowance: 0,
  debtLimit: -1000,
  completed: !failed,
  failed: failed,
);

void main() {
  test('rewards a cash-positive cycle with a savings buffer', () {
    final result = resultForRun(run(cash: 500, savings: 1000));
    expect(result.outcome, PayCycleOutcome.greatMonth);
    expect(result.score, 25);
  });

  test('explains debt-limit failure with a lesson', () {
    final result = resultForRun(run(cash: -1100, failed: true));
    expect(result.outcome, PayCycleOutcome.debtLimitReached);
    expect(result.lesson, isNotEmpty);
  });
}
