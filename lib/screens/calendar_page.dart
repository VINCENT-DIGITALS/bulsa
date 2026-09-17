import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.store});

  final LocalGameStore store;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Future<WeekendPaydayPolicy> _policyFuture;

  @override
  void initState() {
    super.initState();
    _policyFuture = widget.store.loadWeekendPaydayPolicy();
  }

  Future<void> _setPolicy(WeekendPaydayPolicy policy) async {
    await widget.store.saveWeekendPaydayPolicy(policy);
    setState(() => _policyFuture = Future.value(policy));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeekendPaydayPolicy>(
      future: _policyFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final policy = snapshot.data!;
        final today = DateTime.now();
        final paydays = PaySchedule(
          rules: const [PaydayRule.fifteenth, PaydayRule.monthEnd],
          weekendPolicy: policy,
        ).paydaysForMonth(today.year, today.month);
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
              message: 'Weekend policy: ${_policyLabel(policy)}.',
            ),
            const SizedBox(height: BulsaSpacing.large),
            SegmentedButton<WeekendPaydayPolicy>(
              segments: const [
                ButtonSegment(
                  value: WeekendPaydayPolicy.previousFriday,
                  label: Text('Advance'),
                ),
                ButtonSegment(
                  value: WeekendPaydayPolicy.keepDate,
                  label: Text('Keep date'),
                ),
                ButtonSegment(
                  value: WeekendPaydayPolicy.nextMonday,
                  label: Text('Delay'),
                ),
              ],
              selected: {policy},
              onSelectionChanged: (selection) => _setPolicy(selection.single),
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            for (final payday in paydays) ...[
              _PaydayCard(payday: payday),
              const SizedBox(height: BulsaSpacing.small),
            ],
          ],
        );
      },
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

String _policyLabel(WeekendPaydayPolicy policy) => switch (policy) {
  WeekendPaydayPolicy.previousFriday => 'advance to previous Friday',
  WeekendPaydayPolicy.keepDate => 'keep scheduled date',
  WeekendPaydayPolicy.nextMonday => 'delay to next Monday',
};
