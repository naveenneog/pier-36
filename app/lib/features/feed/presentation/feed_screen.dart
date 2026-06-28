import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../auth/presentation/auth_controller.dart';
import 'feed_controller.dart';
import 'widgets/story_card.dart';

/// Full-screen vertical Stories/Reels feed.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final auth = ref.watch(authControllerProvider);

    if (state.loading && state.cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null && state.cards.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Failed to load feed: ${state.error}')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          if (state.cards.isEmpty)
            _EmptyFeed(
              signedIn: auth.signedIn,
              onRefresh: () =>
                  ref.read(feedControllerProvider.notifier).load(),
            )
          else
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.cards.length,
              itemBuilder: (context, i) => StoryCard(card: state.cards[i]),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the feed has no cards — e.g. just signed in with no sources yet,
/// so a fresh sign-in never lands on a blank screen.
class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.signedIn, required this.onRefresh});

  final bool signedIn;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              signedIn ? "You're all set" : 'Your feed is empty',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              signedIn
                  ? 'No cards yet. Add a source — GitHub, arXiv, RSS or Reddit — '
                      'and fresh stories will show up here.'
                  : 'Sign in and add sources to start your feed.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => context.push('/settings/sources'),
              icon: const Icon(Icons.add),
              label: const Text('Add sources'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
