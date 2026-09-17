import 'package:bulsa/main.dart';
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
}
