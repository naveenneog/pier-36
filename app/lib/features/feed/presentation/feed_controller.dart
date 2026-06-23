import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_feed_repository.dart';
import '../domain/entities/feed_card.dart';
import '../domain/repositories/feed_repository.dart';

/// Swap this provider's implementation to wire a real backend later.
final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => MockFeedRepository(),
);

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(ref.watch(feedRepositoryProvider))..load();
});

class FeedState {
  const FeedState({
    this.cards = const [],
    this.loading = false,
    this.error,
  });

  final List<FeedCard> cards;
  final bool loading;
  final Object? error;

  FeedState copyWith({List<FeedCard>? cards, bool? loading, Object? error}) {
    return FeedState(
      cards: cards ?? this.cards,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._repo) : super(const FeedState(loading: true));

  final FeedRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      final cards = await _repo.fetchFeed();
      state = FeedState(cards: cards);
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  void toggleLike(String id) =>
      _update(id, (c) => c.copyWith(liked: !c.liked));

  void toggleSave(String id) =>
      _update(id, (c) => c.copyWith(saved: !c.saved));

  void dismiss(String id) {
    state = state.copyWith(
      cards: state.cards.where((c) => c.id != id).toList(),
    );
  }

  void _update(String id, FeedCard Function(FeedCard) fn) {
    state = state.copyWith(
      cards: [
        for (final c in state.cards) if (c.id == id) fn(c) else c,
      ],
    );
  }
}
