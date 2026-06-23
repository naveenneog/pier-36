import 'package:flutter/foundation.dart';

/// A followed content source.
enum SourceKind { github, arxiv, rss, reddit, notesGit }

extension SourceKindX on SourceKind {
  String get label => switch (this) {
        SourceKind.github => 'GitHub',
        SourceKind.arxiv => 'arXiv',
        SourceKind.rss => 'RSS / Blog',
        SourceKind.reddit => 'Reddit',
        SourceKind.notesGit => 'Notes (Git)',
      };

  /// Value stored in the DB `sources.type` column.
  String get dbName => switch (this) {
        SourceKind.github => 'github',
        SourceKind.arxiv => 'arxiv',
        SourceKind.rss => 'rss',
        SourceKind.reddit => 'reddit',
        SourceKind.notesGit => 'notes_git',
      };
}

SourceKind sourceKindFromDb(String? name) => switch (name) {
      'github' => SourceKind.github,
      'arxiv' => SourceKind.arxiv,
      'reddit' => SourceKind.reddit,
      'notes_git' => SourceKind.notesGit,
      _ => SourceKind.rss,
    };

/// A config field for the dynamic source form.
class SourceFieldSpec {
  const SourceFieldSpec(this.key, this.label, {this.isList = false});

  final String key;
  final String label;
  final bool isList;
}

List<SourceFieldSpec> fieldsForKind(SourceKind kind) => switch (kind) {
      SourceKind.github => const [
          SourceFieldSpec('repos', 'Repos (owner/name, comma-separated)', isList: true),
        ],
      SourceKind.arxiv => const [
          SourceFieldSpec('categories', 'Categories (e.g. cs.AI), comma-separated', isList: true),
          SourceFieldSpec('keywords', 'Keywords (comma-separated)', isList: true),
        ],
      SourceKind.rss => const [
          SourceFieldSpec('url', 'Feed URL'),
        ],
      SourceKind.reddit => const [
          SourceFieldSpec('subreddits', 'Subreddits (comma-separated)', isList: true),
        ],
      SourceKind.notesGit => const [
          SourceFieldSpec('repo', 'Git repo (owner/name)'),
        ],
    };

@immutable
class Source {
  const Source({
    required this.id,
    required this.kind,
    required this.name,
    this.config = const {},
    this.enabled = true,
  });

  final String id;
  final SourceKind kind;
  final String name;
  final Map<String, dynamic> config;
  final bool enabled;

  Source copyWith({
    String? id,
    SourceKind? kind,
    String? name,
    Map<String, dynamic>? config,
    bool? enabled,
  }) {
    return Source(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      config: config ?? this.config,
      enabled: enabled ?? this.enabled,
    );
  }
}
