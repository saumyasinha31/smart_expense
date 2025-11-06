import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/ui/widgets/balance_card.dart';

void main() {
  testWidgets('BalanceCard displays balance correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: 150.0),
        ),
      ),
    );

    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('\$150.00'), findsOneWidget);
    expect(find.text('Positive'), findsOneWidget);
  });

  testWidgets('BalanceCard shows negative balance', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: -50.0),
        ),
      ),
    );

    expect(find.text('\$50.00'), findsOneWidget);
    expect(find.text('Negative'), findsOneWidget);
  });
}
