import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/event_selector.dart';
import 'package:bulsa/game/rules/fixed_bills.dart';
import 'package:bulsa/game/rules/pay_cycle_result.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_button.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.store});

  final LocalGameStore store;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<_TodayData> _runFuture;

  @override
  void initState() {
    super.initState();
    _runFuture = _loadTodayData();
  }

  Future<_TodayData> _loadTodayData() async => _TodayData(
    run: await widget.store.loadOrCreatePayCycleRun(),
    profile: await widget.store.loadProfile(),
  );

  Future<void> _selectChoice(GameChoice choice) async {
    setState(() {
      _runFuture = _applyChoice(choice);
    });
    await _runFuture;
  }

  Future<_TodayData> _applyChoice(GameChoice choice) async {
    await widget.store.applyChoice(choice);
    return _loadTodayData();
  }

  Future<void> _restart() async {
    await widget.store.resetPayCycleRun();
    setState(() {
      _runFuture = _loadTodayData();
    });
  }

  Future<void> _moveToSavings(int amount) async {
    setState(() => _runFuture = _saveCash(amount));
    await _runFuture;
  }

  Future<_TodayData> _saveCash(int amount) async {
    await widget.store.moveCashToSavings(amount);
    return _loadTodayData();
  }

  Future<void> _confirmWithdrawal(int amount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw savings?'),
        content: Text(
          'Move ${_peso(amount)} from savings back to available cash? This will be recorded in your ledger.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep saved'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _runFuture = _withdraw(amount));
    await _runFuture;
  }

  Future<_TodayData> _withdraw(int amount) async {
    await widget.store.withdrawSavings(amount);
    return _loadTodayData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TodayData>(
      future: _runFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return BulsaPage(
            title: 'Today',
            description: 'Your daily budgeting game is loading.',
            icon: Icons.today_outlined,
            children: [
              BulsaInfoCard(
                icon: Icons.error_outline,
                title: 'Unable to open your game',
                message: '${snapshot.error}',
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const _LoadingPage();
        }
        return _RunView(
          run: snapshot.data!.run,
          profile: snapshot.data!.profile,
          onChoice: _selectChoice,
          onRestart: _restart,
          onSave: _moveToSavings,
          onWithdraw: _confirmWithdrawal,
        );
      },
    );
  }
}

class _RunView extends StatelessWidget {
  const _RunView({
    required this.run,
    required this.profile,
    required this.onChoice,
    required this.onRestart,
    required this.onSave,
    required this.onWithdraw,
  });

  final GameRun run;
  final PlayerProfile profile;
  final ValueChanged<GameChoice> onChoice;
  final VoidCallback onRestart;
  final ValueChanged<int> onSave;
  final ValueChanged<int> onWithdraw;

  @override
  Widget build(BuildContext context) {
    if (run.failed) {
      return BulsaPage(
        title: 'Pay cycle ended',
        description: 'Review what happened, then begin again with a new plan.',
        icon: Icons.warning_amber_outlined,
        children: [
          _MoneySummary(run: run),
          const SizedBox(height: BulsaSpacing.section),
          BulsaInfoCard(
            icon: Icons.warning_amber_outlined,
            title: 'Debt limit reached',
            message:
                'Cash fell below ${_peso(run.debtLimit)}. Review the ledger and try a different plan.',
          ),
          const SizedBox(height: BulsaSpacing.large),
          BulsaPrimaryButton(
            label: 'Start a new pay cycle',
            onPressed: onRestart,
          ),
        ],
      );
    }
    if (run.completed) {
      final result = resultForRun(run);
      return BulsaPage(
        title: 'Pay cycle complete',
        description: 'Your result is based on the choices you made this cycle.',
        icon: Icons.celebration_outlined,
        children: [
          _MoneySummary(run: run),
          const SizedBox(height: BulsaSpacing.section),
          BulsaInfoCard(
            icon: Icons.celebration_outlined,
            title: result.title,
            message: '${result.message} Score: ${result.score}.',
          ),
          const SizedBox(height: BulsaSpacing.medium),
          BulsaInfoCard(
            icon: Icons.lightbulb_outline,
            title: 'Lesson for next cycle',
            message: result.lesson,
          ),
          const SizedBox(height: BulsaSpacing.large),
          BulsaPrimaryButton(
            label: 'Start a new pay cycle',
            onPressed: onRestart,
          ),
        ],
      );
    }

    final event = eventForProfileDay(
      day: run.currentDay,
      profile: profile,
      seed: run.eventSeed,
    );
    return BulsaPage(
      title: 'Today',
      description:
          'Make one clear choice at a time and keep your cycle on track.',
      icon: Icons.today_outlined,
      children: [
        Text(
          'DAY ${run.currentDay} · ${run.daysRemaining} DAYS TO PAYDAY',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: BulsaSpacing.xSmall),
        Text(
          'Today: ${_shortDate(run.currentDate)} · Payday: ${_shortDate(run.paydayDate)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: BulsaSpacing.medium),
        _MoneySummary(run: run),
        const SizedBox(height: BulsaSpacing.medium),
        _MoneyActions(run: run, onSave: onSave, onWithdraw: onWithdraw),
        const SizedBox(height: BulsaSpacing.medium),
        _NextBill(run: run),
        const SizedBox(height: BulsaSpacing.section),
        _EventCard(event: event, onChoice: onChoice),
      ],
    );
  }
}

class _MoneyActions extends StatelessWidget {
  const _MoneyActions({
    required this.run,
    required this.onSave,
    required this.onWithdraw,
  });

  final GameRun run;
  final ValueChanged<int> onSave;
  final ValueChanged<int> onWithdraw;

  @override
  Widget build(BuildContext context) => BulsaButtonRow(
    children: [
      BulsaSecondaryButton(
        label: 'Save ₱100',
        icon: Icons.savings_outlined,
        onPressed: run.cash >= 100 ? () => onSave(100) : null,
      ),
      BulsaSecondaryButton(
        label: 'Withdraw ₱100',
        icon: Icons.account_balance_wallet_outlined,
        onPressed: run.savings >= 100 ? () => onWithdraw(100) : null,
      ),
    ],
  );
}

class _NextBill extends StatelessWidget {
  const _NextBill({required this.run});

  final GameRun run;

  @override
  Widget build(BuildContext context) {
    final upcomingBills = fixedBills
        .where((bill) => bill.day >= run.currentDay)
        .toList();
    final nextBill = upcomingBills.isEmpty ? null : upcomingBills.first;
    if (nextBill == null) {
      return const BulsaInfoCard(
        icon: Icons.receipt_long_outlined,
        title: 'No more fixed bills this cycle',
        message: 'Your remaining decisions can focus on payday and savings.',
      );
    }
    return BulsaInfoCard(
      icon: Icons.receipt_long_outlined,
      title: 'Next bill: ${nextBill.title} · ${_peso(nextBill.amount)}',
      message:
          'Due on game day ${nextBill.day}. It will be recorded automatically.',
    );
  }
}

class _MoneySummary extends StatelessWidget {
  const _MoneySummary({required this.run});

  final GameRun run;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BulsaSpacing.large),
        child: Row(
          children: [
            Expanded(
              child: _MoneyValue(
                label: 'AVAILABLE CASH',
                value: _peso(run.cash),
              ),
            ),
            const SizedBox(width: BulsaSpacing.large),
            Expanded(
              child: _MoneyValue(label: 'SAVINGS', value: _peso(run.savings)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyValue extends StatelessWidget {
  const _MoneyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: BulsaSpacing.xSmall),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onChoice});

  final GameEvent event;
  final ValueChanged<GameChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BulsaSpacing.prominentCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.isPossibleIncome ? 'POSSIBLE INCOME' : 'DAILY CHOICE',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: BulsaSpacing.small),
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BulsaSpacing.small),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: BulsaSpacing.large),
            for (final choice in event.choices) ...[
              BulsaSecondaryButton(
                label: choice.label,
                onPressed: () => onChoice(choice),
              ),
              const SizedBox(height: BulsaSpacing.small),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayData {
  const _TodayData({required this.run, required this.profile});

  final GameRun run;
  final PlayerProfile profile;
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

String _peso(int amount) {
  final formatted = amount.abs().toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '${amount < 0 ? '−' : ''}₱$formatted';
}

String _shortDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
