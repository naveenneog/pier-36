import '../../feed/domain/entities/feed_card.dart' show SourceType;

/// A major AI figure in the Startup Seed catalog.
class AiFigure {
  const AiFigure({
    required this.id,
    required this.name,
    required this.handle,
    required this.bio,
    required this.topics,
    this.ring = SourceType.notes,
  });

  final String id;
  final String name;
  final String handle;
  final String bio;
  final List<String> topics;

  /// Gradient ring identity for this figure's tile.
  final SourceType ring;
}

/// A themed starter pack of figures.
class SeedPack {
  const SeedPack({required this.title, required this.figures});

  final String title;
  final List<AiFigure> figures;
}
