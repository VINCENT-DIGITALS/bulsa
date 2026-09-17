import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_button.dart';
import 'package:flutter/material.dart';

class BulsaSelectionField extends StatelessWidget {
  const BulsaSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => BulsaSecondaryButton(
    label: '$label: $value',
    icon: Icons.keyboard_arrow_down_rounded,
    onPressed: onPressed,
  );
}

Future<T?> showBulsaSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required T selected,
  required List<T> options,
  required String Function(T option) label,
}) => showModalBottomSheet<T>(
  context: context,
  showDragHandle: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: BulsaRadii.modal),
  ),
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        BulsaSpacing.screenHorizontal,
        BulsaSpacing.small,
        BulsaSpacing.screenHorizontal,
        BulsaSpacing.screenBottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: BulsaSpacing.medium),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: BulsaSpacing.small,
              title: Text(label(option)),
              trailing: option == selected
                  ? const Icon(Icons.check_circle_outline)
                  : null,
              onTap: () => Navigator.pop(context, option),
            ),
        ],
      ),
    ),
  ),
);
