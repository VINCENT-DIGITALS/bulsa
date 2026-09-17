import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/rules/pay_schedule.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_button.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.store});

  final LocalGameStore store;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Future<_CalendarSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  Future<_CalendarSettings> _loadSettings() async => _CalendarSettings(
    policy: await widget.store.loadWeekendPaydayPolicy(),
    startDate: await widget.store.loadRunStartDate(),
  );

  Future<void> _setPolicy(WeekendPaydayPolicy policy) async {
    await widget.store.saveWeekendPaydayPolicy(policy);
    setState(() => _settingsFuture = _loadSettings());
  }

  Future<void> _selectStartDate() async {
    final settings = await _settingsFuture;
    if (!mounted) return;
    final selected = await showDatePicker(
      context: context,
      initialDate: settings.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (selected != null) {
      await widget.store.saveRunStartDate(selected);
      if (mounted) {
        setState(() => _settingsFuture = _loadSettings());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CalendarSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = snapshot.data!;
        final policy = settings.policy;
        final today = settings.startDate;
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
            BulsaSecondaryButton(
              label: 'Run starts: ${_formatDate(today)}',
              onPressed: _selectStartDate,
            ),
            const SizedBox(height: BulsaSpacing.medium),
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

class _CalendarSettings {
  const _CalendarSettings({required this.policy, required this.startDate});

  final WeekendPaydayPolicy policy;
  final DateTime startDate;
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
