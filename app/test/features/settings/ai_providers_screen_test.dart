import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/settings/presentation/ai_providers_screen.dart';

void main() {
  testWidgets('renders the seeded provider with a DEFAULT badge', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AiProvidersScreen()),
      ),
    );
    await tester.pump(); // flush the mock repository load microtask

    expect(find.text('Azure OpenAI (Managed Identity)'), findsOneWidget);
    expect(find.text('DEFAULT'), findsOneWidget);
  });
}
