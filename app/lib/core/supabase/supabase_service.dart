import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The single place that touches `supabase_flutter`. Everything else goes
/// through this wrapper, which stays safe (no-ops) when not initialized.
class SupabaseService {
  SupabaseService._();

  static bool initialized = false;

  static Future<void> init(String url, String anonKey) async {
    if (initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    initialized = true;
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => initialized ? _client.auth.currentUser : null;

  static bool get isSignedIn => currentUser != null;

  static StreamSubscription<AuthState>? listenAuth(void Function() onChange) {
    if (!initialized) return null;
    return _client.auth.onAuthStateChange.listen((_) => onChange());
  }

  static Future<void> signInWithGitHub() async {
    if (!initialized) return;
    await _client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.pier36.app://login-callback/',
    );
  }

  static Future<void> signOut() async {
    if (initialized) await _client.auth.signOut();
  }
}
