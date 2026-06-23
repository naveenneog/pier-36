import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pier_36/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pier 36 boots into the feed', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: Pier36App()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(Pier36App), findsOneWidget);
  });
}
