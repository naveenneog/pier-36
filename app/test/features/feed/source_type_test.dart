import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/feed/domain/entities/feed_card.dart';

void main() {
  test('maps stored source-type strings to SourceType', () {
    expect(sourceTypeFromName('github'), SourceType.github);
    expect(sourceTypeFromName('arxiv'), SourceType.arxiv);
    expect(sourceTypeFromName('rss'), SourceType.blog);
    expect(sourceTypeFromName('blog'), SourceType.blog);
    expect(sourceTypeFromName('reddit'), SourceType.reddit);
    expect(sourceTypeFromName('x'), SourceType.x);
    expect(sourceTypeFromName('newsletter'), SourceType.newsletter);
    expect(sourceTypeFromName('notes_git'), SourceType.notes);
    expect(sourceTypeFromName(null), SourceType.notes);
    expect(sourceTypeFromName('something-else'), SourceType.notes);
  });
}
