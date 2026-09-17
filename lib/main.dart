import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/screens/calendar_page.dart';
import 'package:bulsa/screens/ledger_page.dart';
import 'package:bulsa/screens/profile_page.dart';
import 'package:bulsa/screens/today_page.dart';
import 'package:bulsa/screens/welcome_page.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final store = LocalGameStore.open();
  await store.initialize();
  runApp(BulsaApp(store: store));
}

class BulsaApp extends StatelessWidget {
  const BulsaApp({super.key, this.store});

  final LocalGameStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BULSA',
      debugShowCheckedModeBanner: false,
      theme: buildBulsaTheme(),
      home: store == null
          ? const BulsaHomePage()
          : _BulsaAppEntry(store: store!),
    );
  }
}

class _BulsaAppEntry extends StatefulWidget {
  const _BulsaAppEntry({required this.store});

  final LocalGameStore store;

  @override
  State<_BulsaAppEntry> createState() => _BulsaAppEntryState();
}

class _BulsaAppEntryState extends State<_BulsaAppEntry> {
  late Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = widget.store.loadOnboardingComplete();
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingFuture = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _onboardingFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!snapshot.data!) {
        return WelcomePage(
          store: widget.store,
          onComplete: _completeOnboarding,
        );
      }
      return BulsaHomePage(store: widget.store, initialIndex: 1);
    },
  );
}

class BulsaHomePage extends StatefulWidget {
  const BulsaHomePage({super.key, this.store, this.initialIndex = 0});

  final LocalGameStore? store;
  final int initialIndex;

  @override
  State<BulsaHomePage> createState() => _BulsaHomePageState();
}

class _BulsaHomePageState extends State<BulsaHomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const _placeholderPages = [
    _PlaceholderPage(
      title: 'Today',
      message: 'Your next payday game will begin here.',
      icon: Icons.today_outlined,
    ),
    _PlaceholderPage(
      title: 'Calendar',
      message: 'Your pay cycle and important dates will appear here.',
      icon: Icons.calendar_month_outlined,
    ),
    _PlaceholderPage(
      title: 'Ledger',
      message: 'Every in-game money change will be recorded here.',
      icon: Icons.receipt_long_outlined,
    ),
    _PlaceholderPage(
      title: 'Profile',
      message: 'Your optional work and pay-cycle profile will live here.',
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_selectedIndex) {
        0 when widget.store != null => TodayPage(store: widget.store!),
        1 when widget.store != null => CalendarPage(store: widget.store!),
        2 when widget.store != null => LedgerPage(store: widget.store!),
        3 when widget.store != null => ProfilePage(store: widget.store!),
        _ => SafeArea(child: _placeholderPages[_selectedIndex]),
      },
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: BulsaColors.background,
          boxShadow: BulsaShadows.navigation,
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return BulsaPage(
      title: title,
      description: message,
      icon: icon,
      children: [
        BulsaInfoCard(icon: icon, title: 'Coming soon', message: message),
      ],
    );
  }
}
