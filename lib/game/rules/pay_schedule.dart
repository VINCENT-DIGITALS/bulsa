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
