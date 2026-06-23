import 'package:flutter_test/flutter_test.dart';
import 'package:pier_36/features/settings/data/mock_llm_provider_repository.dart';
import 'package:pier_36/features/settings/domain/llm_provider.dart';
import 'package:pier_36/features/settings/presentation/llm_providers_controller.dart';

LlmProvidersController _controller() =>
    LlmProvidersController(MockLlmProviderRepository());

void main() {
  test('loads the seeded Azure default via DefaultAzureCredential', () async {
    final controller = _controller();
    await controller.reload();
    expect(controller.state, isNotEmpty);
    expect(controller.state.where((p) => p.isDefault), hasLength(1));
    expect(controller.state.first.type, ProviderType.azureOpenAI);
    expect(controller.state.first.authMethod, AuthMethod.defaultAzureCredential);
  });

  test('save adds a provider', () async {
    final controller = _controller();
    await controller.reload();
    final before = controller.state.length;
    await controller.save(LlmProvider.forType(ProviderType.ollama, id: 'ollama-1'));
    expect(controller.state.length, before + 1);
  });

  test('setDefault keeps exactly one default', () async {
    final controller = _controller();
    await controller.reload();
    await controller.save(
      LlmProvider.forType(ProviderType.openAICompatible, id: 'oai-1'),
    );
    await controller.setDefault('oai-1');
    expect(controller.state.where((p) => p.isDefault), hasLength(1));
    expect(controller.state.firstWhere((p) => p.isDefault).id, 'oai-1');
  });

  test('remove deletes a provider', () async {
    final controller = _controller();
    await controller.reload();
    await controller.save(LlmProvider.forType(ProviderType.gemini, id: 'gem-1'));
    await controller.remove('gem-1');
    expect(controller.state.where((p) => p.id == 'gem-1'), isEmpty);
  });

  test('toggleEnabled flips the enabled flag', () async {
    final controller = _controller();
    await controller.reload();
    final id = controller.state.first.id;
    final before = controller.state.first.enabled;
    await controller.toggleEnabled(id);
    expect(controller.state.firstWhere((p) => p.id == id).enabled, !before);
  });
}
