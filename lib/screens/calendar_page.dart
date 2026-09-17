import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  static const _schedule = PaySchedule(
    rules: [PaydayRule.fifteenth, PaydayRule.monthEnd],
    weekendPolicy: WeekendPaydayPolicy.previousFriday,
  );

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final paydays = _schedule.paydaysForMonth(today.year, today.month);
    return BulsaPage(
      title: 'Calendar',
      children: [
        Text(
          'YOUR PAY SCHEDULE',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: BulsaSpacing.medium),
        BulsaInfoCard(
          icon: Icons.calendar_month_outlined,
          title: '15th and month-end',
          message: 'Weekend payday policy: advance to the previous Friday.',
        ),
        const SizedBox(height: BulsaSpacing.xLarge),
        for (final payday in paydays) ...[
          _PaydayCard(payday: payday),
          const SizedBox(height: BulsaSpacing.small),
        ],
      ],
    );
  }
}

class _PaydayCard extends StatelessWidget {
  const _PaydayCard({required this.payday});

  final Payday payday;

  @override
  Widget build(BuildContext context) {
    final adjusted = payday.scheduledDate != payday.payDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BulsaSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payday.rule == PaydayRule.fifteenth
                  ? 'FIRST CUTOFF'
                  : 'SECOND CUTOFF',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: BulsaSpacing.xSmall),
            Text(
              _formatDate(payday.payDate),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: BulsaSpacing.xSmall),
            Text(
              adjusted
                  ? 'Scheduled ${_formatDate(payday.scheduledDate)} · advanced for weekend'
                  : 'Scheduled date kept',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
