enum PaydayRule { fifteenth, monthEnd }

enum WeekendPaydayPolicy { keepDate, previousFriday, nextMonday }

class Payday {
  const Payday({
    required this.scheduledDate,
    required this.payDate,
    required this.rule,
  });

  final DateTime scheduledDate;
  final DateTime payDate;
  final PaydayRule rule;
}

class PaySchedule {
  const PaySchedule({required this.rules, required this.weekendPolicy});

  final List<PaydayRule> rules;
  final WeekendPaydayPolicy weekendPolicy;

  List<Payday> paydaysForMonth(int year, int month) {
    return rules.map((rule) {
      final scheduledDate = switch (rule) {
        PaydayRule.fifteenth => DateTime(year, month, 15),
        PaydayRule.monthEnd => DateTime(year, month + 1, 0),
      };
      return Payday(
        scheduledDate: scheduledDate,
        payDate: _applyWeekendPolicy(scheduledDate),
        rule: rule,
      );
    }).toList();
  }

  Payday nextPaydayAfter(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    for (var offset = 0; offset < 14; offset++) {
      final month = DateTime(normalized.year, normalized.month + offset);
      final candidates = paydaysForMonth(month.year, month.month)
        ..sort((left, right) => left.payDate.compareTo(right.payDate));
      for (final payday in candidates) {
        if (!payday.payDate.isBefore(normalized)) return payday;
      }
    }
    throw StateError('No payday found within the next 14 months.');
  }

  DateTime _applyWeekendPolicy(DateTime date) {
    if (weekendPolicy == WeekendPaydayPolicy.keepDate || !_isWeekend(date)) {
      return date;
    }
    if (weekendPolicy == WeekendPaydayPolicy.previousFriday) {
      return date.subtract(
        Duration(days: date.weekday == DateTime.saturday ? 1 : 2),
      );
    }
    return date.add(Duration(days: date.weekday == DateTime.saturday ? 2 : 1));
  }

  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}
