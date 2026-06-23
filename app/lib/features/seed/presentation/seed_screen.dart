import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/gradient_ring.dart';
import '../data/mock_seed_repository.dart';
import '../data/seed_models.dart';

final seedPacksProvider = FutureProvider<List<SeedPack>>(
  (ref) => MockSeedRepository().fetchPacks(),
);

/// Startup Seed — curated AI-figures starter packs (cold-start fix).
class SeedScreen extends ConsumerWidget {
  const SeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packs = ref.watch(seedPacksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Seed')),
      body: packs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Follow major AI figures to seed your feed and interests.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            for (final pack in data) _PackSection(pack: pack),
          ],
        ),
      ),
    );
  }
}

class _PackSection extends StatelessWidget {
  const _PackSection({required this.pack});

  final SeedPack pack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(pack.title, style: Theme.of(context).textTheme.titleLarge),
        ),
        for (final f in pack.figures) _FigureTile(figure: f),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _FigureTile extends StatefulWidget {
  const _FigureTile({required this.figure});

  final AiFigure figure;

  @override
  State<_FigureTile> createState() => _FigureTileState();
}

class _FigureTileState extends State<_FigureTile> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.figure;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: GradientRing(
        source: f.ring,
        child: const Icon(Icons.person, color: Colors.white70, size: 20),
      ),
      title: Text(f.name),
      subtitle: Text(
        '${f.handle} · ${f.bio}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FilledButton(
        onPressed: () => setState(() => _following = !_following),
        child: Text(_following ? 'Following' : 'Follow'),
      ),
    );
  }
}
