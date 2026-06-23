import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/sources/presentation/sources_screen.dart';

void main() {
  testWidgets('renders the seeded sources', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SourcesScreen())),
    );
    await tester.pump(); // loading -> data (mock returns synchronously)

    expect(find.text('arXiv cs.AI'), findsOneWidget);
    expect(find.text('flutter/flutter'), findsOneWidget);
  });
}
