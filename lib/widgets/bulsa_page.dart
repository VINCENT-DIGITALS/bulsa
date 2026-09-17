import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:flutter/material.dart';

class BulsaPage extends StatelessWidget {
  const BulsaPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(BulsaSpacing.large),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: BulsaSpacing.xLarge),
          ...children,
        ],
      ),
    );
  }
}

class BulsaInfoCard extends StatelessWidget {
  const BulsaInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BulsaSpacing.xLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: BulsaColors.primary),
            const SizedBox(height: BulsaSpacing.large),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BulsaSpacing.small),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
