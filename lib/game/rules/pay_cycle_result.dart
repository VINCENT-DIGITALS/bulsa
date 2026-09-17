import 'package:bulsa/game/models/game_models.dart';

enum PayCycleOutcome { greatMonth, survived, struggling, debtLimitReached }

class PayCycleResult {
  const PayCycleResult({
    required this.outcome,
    required this.title,
    required this.message,
    required this.lesson,
    required this.score,
  });

  final PayCycleOutcome outcome;
  final String title;
  final String message;
  final String lesson;
  final int score;
}

PayCycleResult resultForRun(GameRun run) {
  if (run.failed) {
    return const PayCycleResult(
      outcome: PayCycleOutcome.debtLimitReached,
      title: 'Debt limit reached',
      message: 'This cycle ended below your chosen safety floor.',
      lesson: 'Keep a small cash buffer before taking optional costs.',
      score: 0,
    );
  }
  final score = (run.cash ~/ 100) + (run.savings ~/ 50);
  if (run.savings >= 1000 && run.cash >= 0) {
    return PayCycleResult(
      outcome: PayCycleOutcome.greatMonth,
      title: 'Great month',
      message: 'You reached payday with cash and a growing savings buffer.',
      lesson: 'Protecting savings gives future choices more room.',
      score: score,
    );
  }
  if (run.cash >= 0) {
    return PayCycleResult(
      outcome: PayCycleOutcome.survived,
      title: 'You survived the cycle',
      message: 'Your bills were covered and you stayed above zero.',
      lesson: 'Try moving a small amount to savings earlier next cycle.',
      score: score,
    );
  }
  return PayCycleResult(
    outcome: PayCycleOutcome.struggling,
    title: 'A difficult cycle',
    message: 'You reached payday, but cash is still below zero.',
    lesson: 'Review the ledger for one cost you can plan around next time.',
    score: score,
  );
}
