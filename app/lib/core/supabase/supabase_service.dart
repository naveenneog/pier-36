import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The single place that touches `supabase_flutter`. Everything else goes
/// through this wrapper, which stays safe (no-ops) when not initialized.
class SupabaseService {
  SupabaseService._();

  static bool initialized = false;
  static String? initializedUrl;

  static Future<void> init(String url, String anonKey) async {
    if (initialized) return;
    await Supabase.initialize(url: url, publishableKey: anonKey);
    initialized = true;
    initializedUrl = url;
  }

  /// supabase_flutter can only initialize once per process. If a *different*
  /// URL is saved after the client has already booted, the new connection only
  /// takes effect after a full app restart (handled by `_tryAutoConnect`).
  static bool restartRequiredFor(String url) =>
      initialized && initializedUrl != null && initializedUrl != url;

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => initialized ? client.auth.currentUser : null;

  static bool get isSignedIn => currentUser != null;

  static StreamSubscription<AuthState>? listenAuth(void Function() onChange) {
    if (!initialized) return null;
    return client.auth.onAuthStateChange.listen((_) => onChange());
  }

  static Future<void> signInWithGitHub() async {
    if (!initialized) return;
    await client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.pier36.app://login-callback/',
    );
  }

  static Future<void> signOut() async {
    if (initialized) await client.auth.signOut();
  }
}
