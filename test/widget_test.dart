import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calc/main.dart';
import 'package:calc/core/providers/finance_provider.dart';

void main() {
  testWidgets('App smoke test renders Kanakkan', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FinanceProvider(),
        child: const KanakkanApp(),
      ),
    );

    // Verify app renders (using a generic find.byType since auth/splash requires async setup)
    expect(find.byType(KanakkanApp), findsOneWidget);
  });
}
