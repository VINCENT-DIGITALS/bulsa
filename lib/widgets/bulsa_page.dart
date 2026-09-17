import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:flutter/material.dart';

class BulsaPage extends StatelessWidget {
  const BulsaPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.children,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          BulsaSpacing.screenHorizontal,
          BulsaSpacing.screenTop,
          BulsaSpacing.screenHorizontal,
          BulsaSpacing.screenBottom,
        ),
        children: [
          BulsaPageHeader(icon: icon, title: title, description: description),
          const SizedBox(height: BulsaSpacing.headerToContent),
          ...children,
        ],
      ),
    );
  }
}

class BulsaPageHeader extends StatelessWidget {
  const BulsaPageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BulsaColors.lightGray),
          borderRadius: const BorderRadius.all(BulsaRadii.control),
        ),
        child: SizedBox(width: 48, height: 48, child: Icon(icon)),
      ),
      const SizedBox(height: BulsaSpacing.medium),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: BulsaSpacing.xSmall),
      Text(description, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
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
        padding: const EdgeInsets.all(BulsaSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: BulsaColors.background,
                borderRadius: const BorderRadius.all(BulsaRadii.small),
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: BulsaColors.black),
              ),
            ),
            const SizedBox(height: BulsaSpacing.medium),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BulsaSpacing.small),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
