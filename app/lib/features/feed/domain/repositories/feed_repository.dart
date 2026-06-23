import '../entities/feed_card.dart';

/// Read side of the feed. Implementations: mock now, Supabase + Worker API later.
abstract interface class FeedRepository {
  Future<List<FeedCard>> fetchFeed({String? cursor, int limit = 20});
}
