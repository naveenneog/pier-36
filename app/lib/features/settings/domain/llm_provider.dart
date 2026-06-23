import 'package:flutter/foundation.dart';

/// Supported LLM provider backends.
enum ProviderType { azureOpenAI, openAICompatible, anthropic, gemini, openRouter, ollama }

/// How the gateway authenticates to the provider.
enum AuthMethod { defaultAzureCredential, apiKey, baseUrl }

/// Config fields a provider may expose (drives the dynamic form).
enum ProviderField {
  endpoint,
  deployment,
  apiVersion,
  baseUrl,
  apiKeyRef,
  model,
  embedModel,
  managedIdentityClientId,
}

extension ProviderTypeX on ProviderType {
  String get label => switch (this) {
        ProviderType.azureOpenAI => 'Azure OpenAI',
        ProviderType.openAICompatible => 'OpenAI-compatible',
        ProviderType.anthropic => 'Anthropic',
        ProviderType.gemini => 'Gemini',
        ProviderType.openRouter => 'OpenRouter',
        ProviderType.ollama => 'Ollama (self-hosted)',
      };

  AuthMethod get defaultAuth => switch (this) {
        ProviderType.azureOpenAI => AuthMethod.defaultAzureCredential,
        ProviderType.ollama => AuthMethod.baseUrl,
        _ => AuthMethod.apiKey,
      };
}

extension AuthMethodX on AuthMethod {
  String get label => switch (this) {
        AuthMethod.defaultAzureCredential => 'DefaultAzureCredential (Managed Identity)',
        AuthMethod.apiKey => 'API key',
        AuthMethod.baseUrl => 'Base URL (no key)',
      };
}

extension ProviderFieldX on ProviderField {
  String get label => switch (this) {
        ProviderField.endpoint => 'Endpoint',
        ProviderField.deployment => 'Deployment',
        ProviderField.apiVersion => 'API version',
        ProviderField.baseUrl => 'Base URL',
        ProviderField.apiKeyRef => 'API key (secret reference)',
        ProviderField.model => 'Model',
        ProviderField.embedModel => 'Embedding model',
        ProviderField.managedIdentityClientId => 'Managed identity client ID (optional)',
      };
}

/// The relevant config fields for a given provider type.
List<ProviderField> fieldsFor(ProviderType type) => switch (type) {
      ProviderType.azureOpenAI => const [
          ProviderField.endpoint,
          ProviderField.deployment,
          ProviderField.apiVersion,
          ProviderField.embedModel,
          ProviderField.managedIdentityClientId,
        ],
      ProviderType.openAICompatible || ProviderType.openRouter => const [
          ProviderField.baseUrl,
          ProviderField.apiKeyRef,
          ProviderField.model,
          ProviderField.embedModel,
        ],
      ProviderType.anthropic || ProviderType.gemini => const [
          ProviderField.apiKeyRef,
          ProviderField.model,
        ],
      ProviderType.ollama => const [
          ProviderField.baseUrl,
          ProviderField.model,
        ],
    };

@immutable
class LlmProvider {
  const LlmProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.authMethod,
    this.endpoint,
    this.deployment,
    this.apiVersion,
    this.baseUrl,
    this.apiKeyRef,
    this.model,
    this.embedModel,
    this.managedIdentityClientId,
    this.isDefault = false,
    this.enabled = true,
  });

  /// A new provider with sensible defaults for the given type.
  factory LlmProvider.forType(ProviderType type, {required String id}) {
    return LlmProvider(
      id: id,
      name: type.label,
      type: type,
      authMethod: type.defaultAuth,
      apiVersion: type == ProviderType.azureOpenAI ? '2024-10-21' : null,
      model: 'gpt-4o-mini',
    );
  }

  final String id;
  final String name;
  final ProviderType type;
  final AuthMethod authMethod;
  final String? endpoint;
  final String? deployment;
  final String? apiVersion;
  final String? baseUrl;
  final String? apiKeyRef;
  final String? model;
  final String? embedModel;
  final String? managedIdentityClientId;
  final bool isDefault;
  final bool enabled;

  String? valueOf(ProviderField field) => switch (field) {
        ProviderField.endpoint => endpoint,
        ProviderField.deployment => deployment,
        ProviderField.apiVersion => apiVersion,
        ProviderField.baseUrl => baseUrl,
        ProviderField.apiKeyRef => apiKeyRef,
        ProviderField.model => model,
        ProviderField.embedModel => embedModel,
        ProviderField.managedIdentityClientId => managedIdentityClientId,
      };

  LlmProvider copyWith({bool? isDefault, bool? enabled}) {
    return LlmProvider(
      id: id,
      name: name,
      type: type,
      authMethod: authMethod,
      endpoint: endpoint,
      deployment: deployment,
      apiVersion: apiVersion,
      baseUrl: baseUrl,
      apiKeyRef: apiKeyRef,
      model: model,
      embedModel: embedModel,
      managedIdentityClientId: managedIdentityClientId,
      isDefault: isDefault ?? this.isDefault,
      enabled: enabled ?? this.enabled,
    );
  }
}
