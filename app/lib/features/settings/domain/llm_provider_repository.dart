import 'llm_provider.dart';

/// CRUD for LLM provider configurations. Mock now; Supabase-backed later.
abstract interface class LlmProviderRepository {
  Future<List<LlmProvider>> list();
  Future<void> upsert(LlmProvider provider);
  Future<void> delete(String id);
  Future<void> setDefault(String id);
}
