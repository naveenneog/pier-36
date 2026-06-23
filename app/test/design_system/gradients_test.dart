import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/design_system/gradients.dart';
import 'package:pier_36/features/feed/domain/entities/feed_card.dart';

void main() {
  test('every SourceType maps to a 2+ stop gradient', () {
    for (final s in SourceType.values) {
      expect(AppGradients.forSource(s).colors.length, greaterThanOrEqualTo(2));
    }
  });

  test('topic identities are stable', () {
    expect(AppGradients.forSource(SourceType.notes), AppGradients.aurora);
    expect(AppGradients.forSource(SourceType.github), AppGradients.mint);
    expect(AppGradients.forSource(SourceType.arxiv), AppGradients.frost);
    expect(AppGradients.forSource(SourceType.blog), AppGradients.solar);
    expect(AppGradients.forSource(SourceType.reddit), AppGradients.pulse);
    expect(AppGradients.forSource(SourceType.x), AppGradients.pulse);
    expect(AppGradients.forSource(SourceType.newsletter), AppGradients.nebula);
  });
}
