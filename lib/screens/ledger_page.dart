import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key, required this.store});

  final LocalGameStore store;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late Future<List<LedgerEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.store.loadLedger();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LedgerEntry>>(
      future: _entriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!;
        return BulsaPage(
          title: 'Ledger',
          children: entries.isEmpty
              ? const [
                  BulsaInfoCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'No entries yet',
                    message:
                        'Your choices will appear here with their exact money effect.',
                  ),
                ]
              : [
                  Text(
                    'EVERY IN-GAME MONEY CHANGE',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: BulsaSpacing.medium),
                  for (final entry in entries) ...[
                    _LedgerCard(entry: entry),
                    const SizedBox(height: BulsaSpacing.small),
                  ],
                ],
        );
      },
    );
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.amount >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BulsaSpacing.large),
        child: Row(
          children: [
            Icon(
              isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: BulsaColors.primary,
            ),
            const SizedBox(width: BulsaSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: BulsaSpacing.xSmall),
                  Text(
                    'DAY ${entry.day} · ${entry.category}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Text(
              _signedPeso(entry.amount),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _signedPeso(int amount) {
  final number = amount.abs().toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '${amount >= 0 ? '+' : '−'}₱$number';
}
