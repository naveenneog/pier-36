import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/connection/presentation/connect_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows URL and anon key fields and the connect button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ConnectScreen())),
    );
    await tester.pump();

    expect(find.text('Project URL'), findsOneWidget);
    expect(find.text('Anon / publishable key'), findsOneWidget);
    expect(find.text('Save & Connect'), findsOneWidget);
  });
}
