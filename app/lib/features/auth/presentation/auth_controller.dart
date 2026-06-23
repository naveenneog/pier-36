import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_service.dart';

class AuthStatus {
  const AuthStatus({this.signedIn = false, this.email});

  final bool signedIn;
  final String? email;
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStatus>((ref) {
  return AuthController()..start();
});

class AuthController extends StateNotifier<AuthStatus> {
  AuthController() : super(const AuthStatus());

  StreamSubscription<AuthState>? _sub;

  void start() {
    if (!SupabaseService.initialized) return;
    _refresh();
    _sub = SupabaseService.listenAuth(_refresh);
  }

  void _refresh() {
    final user = SupabaseService.currentUser;
    state = AuthStatus(signedIn: user != null, email: user?.email);
  }

  Future<void> signInWithGitHub() => SupabaseService.signInWithGitHub();

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _refresh();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
