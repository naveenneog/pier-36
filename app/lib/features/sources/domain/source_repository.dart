import 'source.dart';

/// CRUD for the user's content sources. Mock now; Supabase-backed when signed in.
abstract interface class SourceRepository {
  Future<List<Source>> list();
  Future<void> upsert(Source source);
  Future<void> delete(String id);
}
