import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:flutter/material.dart';

class BulsaPrimaryButton extends StatelessWidget {
  const BulsaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? ElevatedButton(onPressed: onPressed, child: Text(label))
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
    return SizedBox(width: double.infinity, child: child);
  }
}

class BulsaSecondaryButton extends StatelessWidget {
  const BulsaSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
    return SizedBox(width: double.infinity, child: child);
  }
}

/// Keeps related actions visibly paired. Supply one full-width action or two
/// equal-width actions; additional actions belong in another group.
class BulsaButtonRow extends StatelessWidget {
  const BulsaButtonRow({super.key, required this.children})
    : assert(children.length > 0 && children.length <= 2);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.length == 1) return children.single;
    return Row(
      children: [
        Expanded(child: children.first),
        const SizedBox(width: BulsaSpacing.actionGap),
        Expanded(child: children.last),
      ],
    );
  }
}
