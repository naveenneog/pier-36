import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/feed/domain/entities/feed_card.dart';
import 'package:pier_36/features/feed/presentation/widgets/story_card.dart';

void main() {
  testWidgets('StoryCard renders title, summary and tags', (tester) async {
    final card = FeedCard(
      id: '1',
      title: 'Hello World',
      summaryShort: 'A short summary',
      summaryLong: 'Long body',
      source: SourceType.arxiv,
      sourceLabel: 'arXiv',
      tags: const ['AI'],
      url: 'https://example.com',
      publishedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: StoryCard(card: card))),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('A short summary'), findsOneWidget);
    expect(find.text('#AI'), findsOneWidget);
  });
}
