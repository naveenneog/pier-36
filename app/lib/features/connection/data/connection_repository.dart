import 'package:shared_preferences/shared_preferences.dart';

import '../domain/supabase_config.dart';

/// Persists the Supabase connection so users configure it once (click-through).
abstract interface class ConnectionRepository {
  Future<SupabaseConfig?> load();
  Future<void> save(SupabaseConfig config);
  Future<void> clear();
}

class SharedPrefsConnectionRepository implements ConnectionRepository {
  static const _urlKey = 'supabase_url';
  static const _anonKeyKey = 'supabase_anon_key';

  @override
  Future<SupabaseConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_urlKey);
    final anon = prefs.getString(_anonKeyKey);
    if (url == null || url.isEmpty || anon == null || anon.isEmpty) {
      return null;
    }
    return SupabaseConfig(url: url, anonKey: anon);
  }

  @override
  Future<void> save(SupabaseConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, config.url);
    await prefs.setString(_anonKeyKey, config.anonKey);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
    await prefs.remove(_anonKeyKey);
  }
}
