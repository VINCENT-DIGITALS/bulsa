import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_button.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.store, required this.onComplete});

  final LocalGameStore store;
  final VoidCallback onComplete;

  Future<void> _start() async {
    await store.saveOnboardingComplete();
    onComplete();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BulsaPage(
      title: 'Welcome to BULSA',
      description: 'A small offline game about making your pay cycle last.',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        const BulsaInfoCard(
          icon: Icons.calendar_month_outlined,
          title: '1. Set your pay schedule',
          message:
              'Choose a start date and decide what happens when payday falls on a weekend.',
        ),
        const SizedBox(height: BulsaSpacing.medium),
        const BulsaInfoCard(
          icon: Icons.touch_app_outlined,
          title: '2. Make one choice each day',
          message:
              'Pay bills, protect savings, and respond to fictional everyday situations.',
        ),
        const SizedBox(height: BulsaSpacing.medium),
        const BulsaInfoCard(
          icon: Icons.receipt_long_outlined,
          title: '3. Follow every change',
          message:
              'The ledger explains each in-game money change. No account is needed.',
        ),
        const SizedBox(height: BulsaSpacing.section),
        BulsaPrimaryButton(
          label: 'Set up my pay schedule',
          icon: Icons.calendar_month_outlined,
          onPressed: _start,
        ),
      ],
    ),
  );
}
