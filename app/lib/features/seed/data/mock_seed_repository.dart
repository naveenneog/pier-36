import '../../feed/domain/entities/feed_card.dart' show SourceType;
import 'seed_models.dart';

/// Mock Startup Seed catalog. Real version syncs from `seed-catalog/figures.json`.
class MockSeedRepository {
  Future<List<SeedPack>> fetchPacks() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _packs;
  }

  static const List<SeedPack> _packs = [
    SeedPack(
      title: 'Frontier Labs & LLMs',
      figures: [
        AiFigure(
          id: 'karpathy',
          name: 'Andrej Karpathy',
          handle: '@karpathy',
          bio: 'LLMs, neural nets, education',
          topics: ['LLMs', 'Neural Nets', 'Education'],
          ring: SourceType.github,
        ),
        AiFigure(
          id: 'ilyasut',
          name: 'Ilya Sutskever',
          handle: '@ilyasut',
          bio: 'Deep learning, AGI safety',
          topics: ['Deep Learning', 'AGI'],
          ring: SourceType.arxiv,
        ),
      ],
    ),
    SeedPack(
      title: 'Deep Learning Pioneers',
      figures: [
        AiFigure(
          id: 'ylecun',
          name: 'Yann LeCun',
          handle: '@ylecun',
          bio: 'CNNs, self-supervised learning',
          topics: ['CNNs', 'SSL'],
          ring: SourceType.arxiv,
        ),
        AiFigure(
          id: 'drfeifei',
          name: 'Fei-Fei Li',
          handle: '@drfeifei',
          bio: 'Computer vision, ImageNet',
          topics: ['Vision', 'AI4Good'],
          ring: SourceType.arxiv,
        ),
      ],
    ),
    SeedPack(
      title: 'Educators & Builders',
      figures: [
        AiFigure(
          id: 'andrewyng',
          name: 'Andrew Ng',
          handle: '@AndrewYNg',
          bio: 'ML education, applied AI',
          topics: ['ML', 'Education'],
          ring: SourceType.blog,
        ),
        AiFigure(
          id: 'jeremyphoward',
          name: 'Jeremy Howard',
          handle: '@jeremyphoward',
          bio: 'fast.ai, practical deep learning',
          topics: ['fast.ai', 'DL'],
          ring: SourceType.blog,
        ),
      ],
    ),
  ];
}
