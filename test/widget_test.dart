import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calc/main.dart';
import 'package:calc/core/providers/finance_provider.dart';

void main() {
  testWidgets('App smoke test renders FinanceFlow', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FinanceProvider(),
        child: const FinanceFlowApp(),
      ),
    );

    // Verify app renders with Dashboard title or greeting
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });
}
