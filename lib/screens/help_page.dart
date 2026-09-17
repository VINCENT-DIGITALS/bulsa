import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

/// Local, truthful support and privacy information for the offline release.
///
/// Public support destinations are deliberately absent until the owner verifies
/// them and the later backend configuration repository can supply them.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BulsaPage(
      title: 'Help & privacy',
      description: 'Understand the game, your local data, and support status.',
      icon: Icons.help_outline,
      children: const [
        BulsaInfoCard(
          icon: Icons.auto_stories_outlined,
          title: 'How BULSA works',
          message:
              'Set your pay schedule in Calendar, make one everyday choice at a time, and use Ledger to understand every in-game cash change.',
        ),
        SizedBox(height: BulsaSpacing.section),
        BulsaInfoCard(
          icon: Icons.storage_outlined,
          title: 'Your data in this release',
          message:
              'Your profile, schedule, game runs, and ledger are stored on this device. Cloud sync and sign-in are not available in this release.',
        ),
        SizedBox(height: BulsaSpacing.section),
        BulsaInfoCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy policy',
          message:
              'A public privacy-policy link will appear here after the release owner publishes and verifies it. This app does not show a placeholder link.',
        ),
        SizedBox(height: BulsaSpacing.section),
        BulsaInfoCard(
          icon: Icons.support_agent_outlined,
          title: 'Support contact',
          message:
              'A public support contact has not been configured yet. Once verified, it can be updated from the backend without embedding an email address or URL in the app.',
        ),
      ],
    ),
  );
}
