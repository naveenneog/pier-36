import '../domain/entities/feed_card.dart';
import '../domain/repositories/feed_repository.dart';

/// In-memory mock feed so the UI is runnable before the backend lands.
class MockFeedRepository implements FeedRepository {
  @override
  Future<List<FeedCard>> fetchFeed({String? cursor, int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _seed;
  }

  static final List<FeedCard> _seed = [
    FeedCard(
      id: 'c1',
      title: 'A recipe for training neural nets',
      summaryShort:
          'Karpathy distills a battle-tested checklist for debugging and training deep nets reliably.',
      summaryLong:
          'The post argues most training failures are silent. It recommends becoming one with the data, '
          'setting up an end-to-end skeleton + dumb baseline, overfitting a single batch, then regularizing '
          'and tuning — in that order.',
      source: SourceType.blog,
      sourceLabel: 'Blog · karpathy.github.io',
      tags: const ['Neural Nets', 'Training', 'Debugging'],
      url: 'https://karpathy.github.io/2019/04/25/recipe/',
      author: 'Andrej Karpathy',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FeedCard(
      id: 'c2',
      title: 'flutter/flutter — v3.27 released',
      summaryShort:
          'New release adds impeller-by-default on Android and several Material 3 polish fixes.',
      summaryLong:
          'Highlights: Impeller enabled by default on Android, widget previews, DevTools improvements, '
          'and numerous a11y + text-rendering fixes. See the full release notes for breaking changes.',
      source: SourceType.github,
      sourceLabel: 'GitHub · flutter/flutter',
      tags: const ['Flutter', 'Release', 'Impeller'],
      url: 'https://github.com/flutter/flutter/releases',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    FeedCard(
      id: 'c3',
      title: 'Scaling laws for retrieval-augmented generation',
      summaryShort:
          'New paper studies how RAG quality scales with retriever size vs. generator size under fixed compute.',
      summaryLong:
          'The authors find that, under a fixed compute budget, investing in retriever quality yields better '
          'factuality returns than scaling the generator alone, with a crossover point that depends on corpus size.',
      source: SourceType.arxiv,
      sourceLabel: 'arXiv · cs.CL',
      tags: const ['RAG', 'Scaling Laws', 'LLMs'],
      url: 'https://arxiv.org/list/cs.CL/recent',
      publishedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    FeedCard(
      id: 'c4',
      title: 'Show HN-style thread: what broke in your RAG stack?',
      summaryShort:
          'A lively r/MachineLearning thread collects real-world failure modes and fixes for production RAG.',
      summaryLong:
          'Top comments cover chunking strategies, eval harnesses, hybrid search (BM25 + vectors), and the '
          'importance of reranking. Several practitioners share before/after metrics.',
      source: SourceType.reddit,
      sourceLabel: 'Reddit · r/MachineLearning',
      tags: const ['RAG', 'Production', 'Discussion'],
      url: 'https://www.reddit.com/r/MachineLearning/',
      publishedAt: DateTime.now().subtract(const Duration(hours: 14)),
    ),
    FeedCard(
      id: 'c5',
      title: 'Note: Pier 36 ranking score',
      summaryShort:
          'Your own note on the feed ranking formula resurfaced and links to two related papers.',
      summaryLong:
          'score = w1·recency + w2·source_weight + w3·cosine(card, interests) + w4·engagement. '
          'TODO: tune weights with an offline eval set; consider time-decay half-life of 18h.',
      source: SourceType.notes,
      sourceLabel: 'Second Brain · /inbox',
      tags: const ['Ranking', 'Design'],
      url: 'https://example.com/notes/ranking',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
