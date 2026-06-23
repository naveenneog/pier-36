import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_llm_provider_repository.dart';
import '../domain/llm_provider.dart';
import '../domain/llm_provider_repository.dart';

final llmProviderRepositoryProvider = Provider<LlmProviderRepository>(
  (ref) => MockLlmProviderRepository(),
);

final llmProvidersControllerProvider =
    StateNotifierProvider<LlmProvidersController, List<LlmProvider>>((ref) {
  return LlmProvidersController(ref.watch(llmProviderRepositoryProvider))..reload();
});

class LlmProvidersController extends StateNotifier<List<LlmProvider>> {
  LlmProvidersController(this._repo) : super(const []);

  final LlmProviderRepository _repo;

  Future<void> reload() async {
    state = await _repo.list();
  }

  Future<void> save(LlmProvider provider) async {
    await _repo.upsert(provider);
    await reload();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await reload();
  }

  Future<void> setDefault(String id) async {
    await _repo.setDefault(id);
    await reload();
  }

  Future<void> toggleEnabled(String id) async {
    final current = state.firstWhere((p) => p.id == id);
    await _repo.upsert(current.copyWith(enabled: !current.enabled));
    await reload();
  }
}
