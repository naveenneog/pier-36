import '../domain/source.dart';
import '../domain/source_repository.dart';

/// In-memory sources for demo mode (not connected / not signed in).
class MockSourceRepository implements SourceRepository {
  final List<Source> _items = [
    const Source(
      id: 'seed-arxiv',
      kind: SourceKind.arxiv,
      name: 'arXiv cs.AI',
      config: {
        'categories': ['cs.AI'],
      },
    ),
    const Source(
      id: 'seed-github',
      kind: SourceKind.github,
      name: 'flutter/flutter',
      config: {
        'repos': ['flutter/flutter'],
      },
    ),
  ];
  int _counter = 0;

  @override
  Future<List<Source>> list() async => List.unmodifiable(_items);

  @override
  Future<void> upsert(Source source) async {
    if (source.id.isEmpty) {
      _items.add(source.copyWith(id: 'local-${_counter++}'));
      return;
    }
    final index = _items.indexWhere((s) => s.id == source.id);
    if (index >= 0) {
      _items[index] = source;
    } else {
      _items.add(source);
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((s) => s.id == id);
  }
}
