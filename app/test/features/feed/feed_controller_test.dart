import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/feed/domain/entities/feed_card.dart';
import 'package:pier_36/features/feed/domain/repositories/feed_repository.dart';
import 'package:pier_36/features/feed/presentation/feed_controller.dart';

class _FakeRepo implements FeedRepository {
  @override
  Future<List<FeedCard>> fetchFeed({String? cursor, int limit = 20}) async => [
        FeedCard(
          id: '1',
          title: 'T',
          summaryShort: 's',
          summaryLong: 'l',
          source: SourceType.github,
          sourceLabel: 'GitHub',
          tags: const ['x'],
          url: 'https://example.com',
          publishedAt: DateTime(2026, 1, 1),
        ),
      ];
}

void main() {
  test('load populates cards and clears loading', () async {
    final controller = FeedController(_FakeRepo());
    await controller.load();
    expect(controller.state.cards, hasLength(1));
    expect(controller.state.loading, isFalse);
  });

  test('toggleLike flips liked optimistically', () async {
    final controller = FeedController(_FakeRepo());
    await controller.load();
    expect(controller.state.cards.first.liked, isFalse);
    controller.toggleLike('1');
    expect(controller.state.cards.first.liked, isTrue);
  });

  test('dismiss removes the card', () async {
    final controller = FeedController(_FakeRepo());
    await controller.load();
    controller.dismiss('1');
    expect(controller.state.cards, isEmpty);
  });
}
