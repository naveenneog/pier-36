import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../domain/llm_provider.dart';
import 'llm_providers_controller.dart';

/// Add/edit a provider. Fields adapt to the selected [ProviderType].
class ProviderFormScreen extends ConsumerStatefulWidget {
  const ProviderFormScreen({this.initial, super.key});

  final LlmProvider? initial;

  @override
  ConsumerState<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends ConsumerState<ProviderFormScreen> {
  late ProviderType _type;
  late AuthMethod _authMethod;
  late bool _isDefault;
  late bool _enabled;
  late final TextEditingController _name;
  final Map<ProviderField, TextEditingController> _fields = {};

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _type = p?.type ?? ProviderType.azureOpenAI;
    _authMethod = p?.authMethod ?? _type.defaultAuth;
    _isDefault = p?.isDefault ?? false;
    _enabled = p?.enabled ?? true;
    _name = TextEditingController(text: p?.name ?? _type.label);
    for (final field in ProviderField.values) {
      _fields[field] = TextEditingController(text: p?.valueOf(field) ?? _suggest(field));
    }
  }

  String _suggest(ProviderField field) => switch (field) {
        ProviderField.apiVersion => '2024-10-21',
        ProviderField.embedModel => 'text-embedding-3-small',
        ProviderField.model => 'gpt-4o-mini',
        _ => '',
      };

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTypeChanged(ProviderType type) {
    setState(() {
      _type = type;
      _authMethod = type.defaultAuth;
    });
  }

  Future<void> _save() async {
    String? read(ProviderField field) {
      final text = _fields[field]!.text.trim();
      return text.isEmpty ? null : text;
    }

    final id = widget.initial?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final name = _name.text.trim();
    final provider = LlmProvider(
      id: id,
      name: name.isEmpty ? _type.label : name,
      type: _type,
      authMethod: _authMethod,
      endpoint: read(ProviderField.endpoint),
      deployment: read(ProviderField.deployment),
      apiVersion: read(ProviderField.apiVersion),
      baseUrl: read(ProviderField.baseUrl),
      apiKeyRef: read(ProviderField.apiKeyRef),
      model: read(ProviderField.model),
      embedModel: read(ProviderField.embedModel),
      managedIdentityClientId: read(ProviderField.managedIdentityClientId),
      isDefault: _isDefault,
      enabled: _enabled,
    );
    await ref.read(llmProvidersControllerProvider.notifier).save(provider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final fields = fieldsFor(_type);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Add provider' : 'Edit provider'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.lg),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Provider type'),
            child: DropdownButton<ProviderType>(
              value: _type,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final t in ProviderType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (t) {
                if (t != null) _onTypeChanged(t);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Auth method'),
            child: Text(_authMethod.label),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final field in fields) ...[
            TextField(
              controller: _fields[field],
              decoration: InputDecoration(labelText: field.label),
              obscureText: field == ProviderField.apiKeyRef,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SwitchListTile(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            title: const Text('Default provider'),
          ),
          SwitchListTile(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            title: const Text('Enabled'),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
