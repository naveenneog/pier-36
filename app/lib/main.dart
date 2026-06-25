import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/supabase/supabase_service.dart';
import 'features/connection/data/connection_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _tryAutoConnect();
  SupabaseService.installAuthErrorGuard();
  runApp(const ProviderScope(child: Pier36App()));
}

Future<void> _tryAutoConnect() async {
  try {
    final config = await SharedPrefsConnectionRepository().load();
    if (config != null) {
      await SupabaseService.init(config.url, config.anonKey);
    }
  } catch (_) {
    // No saved config or platform storage unavailable — run the demo.
  }
}
