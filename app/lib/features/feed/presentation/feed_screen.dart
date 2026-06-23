import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_controller.dart';
import 'widgets/story_card.dart';

/// Full-screen vertical Stories/Reels feed.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);

    if (state.loading && state.cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null && state.cards.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Failed to load feed: ${state.error}')),
      );
    }

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: state.cards.length,
        itemBuilder: (context, i) => StoryCard(card: state.cards[i]),
      ),
    );
  }
}
