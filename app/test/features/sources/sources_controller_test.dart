import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/sources/data/mock_source_repository.dart';
import 'package:pier_36/features/sources/domain/source.dart';
import 'package:pier_36/features/sources/presentation/sources_controller.dart';

void main() {
  test('loads seeded sources', () async {
    final controller = SourcesController(MockSourceRepository());
    await controller.load();
    expect(controller.state.value, isNotNull);
    expect(controller.state.value!, isNotEmpty);
  });

  test('save with empty id adds a source', () async {
    final controller = SourcesController(MockSourceRepository());
    await controller.load();
    final before = controller.state.value!.length;
    await controller.save(
      const Source(
        id: '',
        kind: SourceKind.rss,
        name: 'My blog',
        config: {'url': 'https://b.com/feed'},
      ),
    );
    expect(controller.state.value!.length, before + 1);
  });

  test('remove deletes a source', () async {
    final controller = SourcesController(MockSourceRepository());
    await controller.load();
    final id = controller.state.value!.first.id;
    await controller.remove(id);
    expect(controller.state.value!.where((s) => s.id == id), isEmpty);
  });

  test('toggleEnabled flips the enabled flag', () async {
    final controller = SourcesController(MockSourceRepository());
    await controller.load();
    final source = controller.state.value!.first;
    await controller.toggleEnabled(source);
    expect(
      controller.state.value!.firstWhere((s) => s.id == source.id).enabled,
      !source.enabled,
    );
  });
}
