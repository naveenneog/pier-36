import '../../../core/supabase/supabase_service.dart';
import '../domain/source.dart';
import '../domain/source_repository.dart';

/// Reads/writes the per-user `sources` table (RLS-scoped to the signed-in user).
class SupabaseSourceRepository implements SourceRepository {
  @override
  Future<List<Source>> list() async {
    final rows = await SupabaseService.client
        .from('sources')
        .select('id, type, name, config, enabled')
        .order('created_at');
    return [for (final row in rows) _map(row)];
  }

  @override
  Future<void> upsert(Source source) async {
    final row = <String, dynamic>{
      'owner': SupabaseService.currentUser?.id,
      'type': source.kind.dbName,
      'name': source.name,
      'config': source.config,
      'enabled': source.enabled,
    };
    final client = SupabaseService.client;
    if (source.id.isEmpty) {
      await client.from('sources').insert(row);
    } else {
      await client.from('sources').update(row).eq('id', source.id);
    }
  }

  @override
  Future<void> delete(String id) async {
    await SupabaseService.client.from('sources').delete().eq('id', id);
  }

  Source _map(Map<String, dynamic> row) {
    final config =
        (row['config'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    return Source(
      id: (row['id'] ?? '').toString(),
      kind: sourceKindFromDb(row['type']?.toString()),
      name: (row['name'] ?? '').toString(),
      config: config,
      enabled: (row['enabled'] as bool?) ?? true,
    );
  }
}
