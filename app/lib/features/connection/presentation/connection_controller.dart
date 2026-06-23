import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_service.dart';
import '../data/connection_repository.dart';
import '../domain/supabase_config.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>(
  (ref) => SharedPrefsConnectionRepository(),
);

class ConnectionState {
  const ConnectionState({this.loading = true, this.config});

  final bool loading;
  final SupabaseConfig? config;

  bool get isConnected => config != null;
}

final connectionControllerProvider =
    StateNotifierProvider<ConnectionController, ConnectionState>((ref) {
  return ConnectionController(ref.watch(connectionRepositoryProvider))..load();
});

class ConnectionController extends StateNotifier<ConnectionState> {
  ConnectionController(this._repo) : super(const ConnectionState());

  final ConnectionRepository _repo;

  Future<void> load() async {
    final config = await _repo.load();
    state = ConnectionState(loading: false, config: config);
  }

  Future<void> save(SupabaseConfig config) async {
    await _repo.save(config);
    await SupabaseService.init(config.url, config.anonKey);
    state = ConnectionState(loading: false, config: config);
  }

  Future<void> disconnect() async {
    await _repo.clear();
    state = const ConnectionState(loading: false, config: null);
  }
}
