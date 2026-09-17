import 'package:bulsa/main.dart';
import 'package:bulsa/screens/help_page.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the BULSA app shell and navigation', (tester) async {
    await tester.pumpWidget(const BulsaApp());

    expect(find.text('Today'), findsNWidgets(2));
    expect(
      find.text('Your next payday game will begin here.'),
      findsNWidgets(2),
    );
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('shows truthful local help without a placeholder contact', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildBulsaTheme(), home: const HelpPage()),
    );

    expect(find.text('Help & privacy'), findsOneWidget);
    expect(find.text('Your data in this release'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Support contact'), 200);
    expect(find.text('Support contact'), findsOneWidget);
    expect(find.textContaining('has not been configured yet'), findsOneWidget);
  });
}
