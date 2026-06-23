import '../../../core/supabase/supabase_service.dart';
import '../domain/entities/feed_card.dart';
import '../domain/repositories/feed_repository.dart';

/// Reads the live feed (`feed_ranked` joined with `cards`) for the signed-in user.
class SupabaseFeedRepository implements FeedRepository {
  @override
  Future<List<FeedCard>> fetchFeed({String? cursor, int limit = 20}) async {
    final rows = await SupabaseService.client
        .from('feed_ranked')
        .select(
          'score, cards!inner(content_hash, title, url, source_type, '
          'source_label, author, summary_short, summary_long, tags, published_at)',
        )
        .order('score', ascending: false)
        .limit(limit);
    return [for (final row in rows) _map(row)];
  }

  FeedCard _map(Map<String, dynamic> row) {
    final card =
        (row['cards'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final tags =
        (card['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    return FeedCard(
      id: (card['content_hash'] ?? '').toString(),
      title: (card['title'] ?? '').toString(),
      summaryShort: (card['summary_short'] ?? '').toString(),
      summaryLong: (card['summary_long'] ?? '').toString(),
      source: sourceTypeFromName(card['source_type']?.toString()),
      sourceLabel: (card['source_label'] ?? '').toString(),
      tags: tags,
      url: (card['url'] ?? '').toString(),
      author: card['author']?.toString(),
      publishedAt:
          DateTime.tryParse(card['published_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
