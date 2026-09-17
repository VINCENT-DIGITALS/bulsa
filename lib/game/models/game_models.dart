class GameRun {
  const GameRun({
    required this.currentDay,
    required this.totalDays,
    required this.cash,
    required this.savings,
    required this.completed,
  });

  final int currentDay;
  final int totalDays;
  final int cash;
  final int savings;
  final bool completed;

  int get daysRemaining => completed ? 0 : totalDays - currentDay + 1;
}

class LedgerEntry {
  const LedgerEntry({
    required this.day,
    required this.amount,
    required this.category,
    required this.description,
  });

  final int day;
  final int amount;
  final String category;
  final String description;
}

class GameChoice {
  const GameChoice({
    required this.label,
    required this.amount,
    required this.category,
    required this.description,
  });

  final String label;
  final int amount;
  final String category;
  final String description;
}

class GameEvent {
  const GameEvent({
    required this.day,
    required this.title,
    required this.description,
    required this.choices,
  });

  final int day;
  final String title;
  final String description;
  final List<GameChoice> choices;
}
