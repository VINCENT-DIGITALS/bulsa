import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BulsaApp());
}

class BulsaApp extends StatelessWidget {
  const BulsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BULSA',
      debugShowCheckedModeBanner: false,
      theme: buildBulsaTheme(),
      home: const BulsaHomePage(),
    );
  }
}

class BulsaHomePage extends StatefulWidget {
  const BulsaHomePage({super.key});

  @override
  State<BulsaHomePage> createState() => _BulsaHomePageState();
}

class _BulsaHomePageState extends State<BulsaHomePage> {
  int _selectedIndex = 0;

  static const _pages = [
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
      appBar: AppBar(title: const Text('BULSA')),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: BulsaColors.primary),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
