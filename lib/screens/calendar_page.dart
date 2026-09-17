import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
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
    confirmedSalary: await widget.store.loadConfirmedSalary(),
    recurringAllowance: await widget.store.loadRecurringAllowance(),
    activeRun: await widget.store.loadPayCycleRun(),
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

  Future<void> _editPaydayIncome(_CalendarSettings settings) async {
    final salaryController = TextEditingController(
      text: settings.confirmedSalary == 0 ? '' : '${settings.confirmedSalary}',
    );
    final allowanceController = TextEditingController(
      text: settings.recurringAllowance == 0
          ? ''
          : '${settings.recurringAllowance}',
    );
    final result = await showDialog<_PaydayIncome>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmed payday income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Salary (₱)',
                helperText: 'Use 0 if no salary is confirmed.',
              ),
            ),
            const SizedBox(height: BulsaSpacing.large),
            TextField(
              controller: allowanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Recurring allowance (₱)',
                helperText: 'Only income guaranteed every payday.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              _PaydayIncome(
                salary: int.tryParse(salaryController.text) ?? 0,
                allowance: int.tryParse(allowanceController.text) ?? 0,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    salaryController.dispose();
    allowanceController.dispose();
    if (result == null || result.salary < 0 || result.allowance < 0) return;

    await widget.store.saveConfirmedSalary(result.salary);
    await widget.store.saveRecurringAllowance(result.allowance);
    if (mounted) {
      setState(() => _settingsFuture = _loadSettings());
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
        final schedule = PaySchedule(
          rules: const [PaydayRule.fifteenth, PaydayRule.monthEnd],
          weekendPolicy: policy,
        );
        final calendarDate =
            settings.activeRun?.startDate ?? settings.startDate;
        final paydays = schedule.paydaysForMonth(
          calendarDate.year,
          calendarDate.month,
        );
        final nextPayday = schedule.nextPaydayAfter(calendarDate);
        return BulsaPage(
          title: 'Calendar',
          description: 'Set the schedule your next pay cycle will follow.',
          icon: Icons.calendar_month_outlined,
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
              label: 'Run starts: ${_formatDate(settings.startDate)}',
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
            BulsaInfoCard(
              icon: Icons.payments_outlined,
              title: 'Next expected payday: ${_formatDate(nextPayday.payDate)}',
              message: _paydayStatus(settings, nextPayday),
            ),
            const SizedBox(height: BulsaSpacing.large),
            BulsaInfoCard(
              icon: Icons.account_balance_wallet_outlined,
              title:
                  'Confirmed income: ${_peso(settings.confirmedSalary + settings.recurringAllowance)}',
              message:
                  'Salary ${_peso(settings.confirmedSalary)} · allowance ${_peso(settings.recurringAllowance)}. Possible incentives are not included.',
            ),
            const SizedBox(height: BulsaSpacing.medium),
            BulsaSecondaryButton(
              label: 'Edit confirmed payday income',
              onPressed: () => _editPaydayIncome(settings),
            ),
            if (settings.activeRun != null) ...[
              const SizedBox(height: BulsaSpacing.medium),
              Text(
                'Changes to this schedule or income apply when you start your next pay cycle.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: BulsaSpacing.large),
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
  const _CalendarSettings({
    required this.policy,
    required this.startDate,
    required this.confirmedSalary,
    required this.recurringAllowance,
    required this.activeRun,
  });

  final WeekendPaydayPolicy policy;
  final DateTime startDate;
  final int confirmedSalary;
  final int recurringAllowance;
  final GameRun? activeRun;
}

class _PaydayIncome {
  const _PaydayIncome({required this.salary, required this.allowance});

  final int salary;
  final int allowance;
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

String _paydayStatus(_CalendarSettings settings, Payday payday) {
  final activeRun = settings.activeRun;
  if (activeRun != null && activeRun.paydayDate == payday.payDate) {
    if (activeRun.completed) {
      return 'Status: Received · recorded in your ledger';
    }
    return 'Status: Pending · this pay cycle is in progress';
  }
  if (payday.payDate == payday.scheduledDate) return 'Status: Expected';
  final timing = settings.policy == WeekendPaydayPolicy.previousFriday
      ? 'Early'
      : 'Late';
  return 'Status: $timing · scheduled ${_formatDate(payday.scheduledDate)}';
}

String _peso(int amount) {
  final formatted = amount.abs().toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '${amount < 0 ? '−' : ''}₱$formatted';
}
