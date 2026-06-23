import '../domain/llm_provider.dart';
import '../domain/llm_provider_repository.dart';

/// In-memory provider store seeded with the Azure DefaultAzureCredential default.
class MockLlmProviderRepository implements LlmProviderRepository {
  final List<LlmProvider> _items = [
    const LlmProvider(
      id: 'azure-default',
      name: 'Azure OpenAI (Managed Identity)',
      type: ProviderType.azureOpenAI,
      authMethod: AuthMethod.defaultAzureCredential,
      endpoint: 'https://YOUR-RESOURCE.openai.azure.com',
      deployment: 'gpt-4o-mini',
      apiVersion: '2024-10-21',
      model: 'gpt-4o-mini',
      embedModel: 'text-embedding-3-small',
      isDefault: true,
    ),
  ];

  @override
  Future<List<LlmProvider>> list() async => List.unmodifiable(_items);

  @override
  Future<void> upsert(LlmProvider provider) async {
    final index = _items.indexWhere((p) => p.id == provider.id);
    if (index >= 0) {
      _items[index] = provider;
    } else {
      _items.add(provider);
    }
    if (provider.isDefault) {
      for (var i = 0; i < _items.length; i++) {
        if (_items[i].id != provider.id && _items[i].isDefault) {
          _items[i] = _items[i].copyWith(isDefault: false);
        }
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> setDefault(String id) async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isDefault: _items[i].id == id);
    }
  }
}
