import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The single place that touches `supabase_flutter`. Everything else goes
/// through this wrapper, which stays safe (no-ops) when not initialized.
class SupabaseService {
  SupabaseService._();

  static bool initialized = false;
  static String? initializedUrl;

  /// The most recent OAuth/auth failure message, surfaced in the UI so sign-in
  /// problems are visible instead of silently swallowed. Cleared on success.
  static final ValueNotifier<String?> lastAuthError = ValueNotifier<String?>(null);

  static Future<void> init(String url, String anonKey) async {
    if (initialized) return;
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      // Use the implicit OAuth flow: the provider redirect carries the session
      // tokens directly in the URL fragment, so there is no PKCE code-exchange.
      // The PKCE exchange was failing on real devices ("flow state not found")
      // even though the GitHub login succeeded server-side.
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
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

  /// supabase_flutter rethrows OAuth deep-link / code-exchange failures (e.g. an
  /// expired, reused, or cancelled GitHub login) as *uncaught* async errors,
  /// which would otherwise crash the app. Swallow only `AuthException`s here and
  /// let every other error propagate to Flutter's normal reporting.
  static void installAuthErrorGuard() {
    final previous = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (error is AuthException) {
        debugPrint('Supabase auth error (handled): ${error.message}');
        lastAuthError.value = error.statusCode != null
            ? '${error.message} (status ${error.statusCode})'
            : error.message;
        return true;
      }
      return previous?.call(error, stack) ?? false;
    };
  }
}
