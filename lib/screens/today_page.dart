import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/game/rules/event_selector.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TodayData>(
      future: _runFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return BulsaPage(
            title: 'Today',
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
  });

  final GameRun run;
  final PlayerProfile profile;
  final ValueChanged<GameChoice> onChoice;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    if (run.completed) {
      return BulsaPage(
        title: 'Pay cycle complete',
        children: [
          _MoneySummary(run: run),
          const SizedBox(height: BulsaSpacing.xLarge),
          BulsaInfoCard(
            icon: Icons.celebration_outlined,
            title: 'You reached payday',
            message:
                'Ending cash: ${_peso(run.cash)}. Review your ledger, then try another pay cycle.',
          ),
          const SizedBox(height: BulsaSpacing.large),
          BulsaPrimaryButton(
            label: 'Start a new pay cycle',
            onPressed: onRestart,
          ),
        ],
      );
    }

    final event = eventForProfileDay(day: run.currentDay, profile: profile);
    return BulsaPage(
      title: 'Today',
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
        const SizedBox(height: BulsaSpacing.xLarge),
        _EventCard(event: event, onChoice: onChoice),
      ],
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
        padding: const EdgeInsets.all(BulsaSpacing.xLarge),
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
