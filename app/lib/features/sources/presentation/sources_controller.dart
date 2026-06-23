import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/mock_source_repository.dart';
import '../data/supabase_source_repository.dart';
import '../domain/source.dart';
import '../domain/source_repository.dart';

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  final auth = ref.watch(authControllerProvider);
  return auth.signedIn ? SupabaseSourceRepository() : MockSourceRepository();
});

final sourcesControllerProvider =
    StateNotifierProvider<SourcesController, AsyncValue<List<Source>>>((ref) {
  return SourcesController(ref.watch(sourceRepositoryProvider))..load();
});

class SourcesController extends StateNotifier<AsyncValue<List<Source>>> {
  SourcesController(this._repo) : super(const AsyncValue.loading());

  final SourceRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.list());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> save(Source source) async {
    await _repo.upsert(source);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> toggleEnabled(Source source) async {
    await _repo.upsert(source.copyWith(enabled: !source.enabled));
    await load();
  }
}
