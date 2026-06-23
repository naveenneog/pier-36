import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/connection/data/connection_repository.dart';
import 'package:pier_36/features/connection/domain/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns null when nothing is stored', () async {
    expect(await SharedPrefsConnectionRepository().load(), isNull);
  });

  test('save then load round-trips the config', () async {
    final repo = SharedPrefsConnectionRepository();
    await repo.save(
      const SupabaseConfig(url: 'https://x.supabase.co', anonKey: 'anon-key'),
    );
    final loaded = await repo.load();
    expect(loaded, isNotNull);
    expect(loaded!.url, 'https://x.supabase.co');
    expect(loaded.anonKey, 'anon-key');
  });

  test('clear removes the stored config', () async {
    final repo = SharedPrefsConnectionRepository();
    await repo.save(
      const SupabaseConfig(url: 'https://x.supabase.co', anonKey: 'anon-key'),
    );
    await repo.clear();
    expect(await repo.load(), isNull);
  });
}
