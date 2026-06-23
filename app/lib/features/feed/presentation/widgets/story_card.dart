import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/gradients.dart';
import '../../../../design_system/tokens.dart';
import '../../domain/entities/feed_card.dart';
import '../feed_controller.dart';
import 'action_bar.dart';

/// A single full-bleed story card. Tap to expand the long summary.
class StoryCard extends ConsumerWidget {
  const StoryCard({required this.card, super.key});

  final FeedCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(feedControllerProvider.notifier);

    return GestureDetector(
      onTap: () => _expand(context),
      child: Container(
        decoration: BoxDecoration(gradient: AppGradients.forSource(card.source)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SourceBadge(label: card.sourceLabel),
                    const Spacer(),
                    Text(
                      _timeAgo(card.publishedAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  card.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  card.summaryShort,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [for (final t in card.tags) _Tag(t)],
                ),
                const Spacer(),
                ActionBar(
                  liked: card.liked,
                  saved: card.saved,
                  onLike: () => controller.toggleLike(card.id),
                  onSave: () => controller.toggleSave(card.id),
                  onDismiss: () => controller.dismiss(card.id),
                  onOpen: () => _expand(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _expand(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(card.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              card.sourceLabel,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              card.summaryLong,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(64),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text('#$label', style: const TextStyle(color: Colors.white)),
    );
  }
}
