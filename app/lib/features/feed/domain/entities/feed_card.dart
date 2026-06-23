import 'package:flutter/foundation.dart';

/// Source a card originates from. Drives the topic gradient identity.
enum SourceType { notes, github, arxiv, blog, reddit, x, newsletter }

/// Maps a stored source-type string (from the worker/db) to a [SourceType].
SourceType sourceTypeFromName(String? name) {
  switch (name) {
    case 'github':
      return SourceType.github;
    case 'arxiv':
      return SourceType.arxiv;
    case 'blog':
    case 'rss':
      return SourceType.blog;
    case 'reddit':
      return SourceType.reddit;
    case 'x':
      return SourceType.x;
    case 'newsletter':
      return SourceType.newsletter;
    case 'notes':
    case 'notes_git':
      return SourceType.notes;
    default:
      return SourceType.notes;
  }
}

/// A single, glanceable feed item (hybrid: short summary up front, long on expand).
@immutable
class FeedCard {
  const FeedCard({
    required this.id,
    required this.title,
    required this.summaryShort,
    required this.summaryLong,
    required this.source,
    required this.sourceLabel,
    required this.tags,
    required this.url,
    required this.publishedAt,
    this.author,
    this.liked = false,
    this.saved = false,
  });

  final String id;
  final String title;
  final String summaryShort;
  final String summaryLong;
  final SourceType source;
  final String sourceLabel;
  final List<String> tags;
  final String url;
  final DateTime publishedAt;
  final String? author;
  final bool liked;
  final bool saved;

  FeedCard copyWith({bool? liked, bool? saved}) {
    return FeedCard(
      id: id,
      title: title,
      summaryShort: summaryShort,
      summaryLong: summaryLong,
      source: source,
      sourceLabel: sourceLabel,
      tags: tags,
      url: url,
      publishedAt: publishedAt,
      author: author,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeedCard &&
      other.id == id &&
      other.liked == liked &&
      other.saved == saved;

  @override
  int get hashCode => Object.hash(id, liked, saved);
}
