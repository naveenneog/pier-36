import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../domain/source.dart';
import 'sources_controller.dart';

/// Add/edit a source. Fields adapt to the selected [SourceKind].
class SourceFormScreen extends ConsumerStatefulWidget {
  const SourceFormScreen({this.initial, super.key});

  final Source? initial;

  @override
  ConsumerState<SourceFormScreen> createState() => _SourceFormScreenState();
}

class _SourceFormScreenState extends ConsumerState<SourceFormScreen> {
  late SourceKind _kind;
  late bool _enabled;
  late final TextEditingController _name;
  final Map<String, TextEditingController> _fields = {};

  @override
  void initState() {
    super.initState();
    final source = widget.initial;
    _kind = source?.kind ?? SourceKind.arxiv;
    _enabled = source?.enabled ?? true;
    _name = TextEditingController(text: source?.name ?? '');
    _rebuildFieldControllers(source);
  }

  void _rebuildFieldControllers(Source? source) {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    _fields.clear();
    for (final spec in fieldsForKind(_kind)) {
      final value = source?.config[spec.key];
      final text = value is List ? value.join(', ') : (value?.toString() ?? '');
      _fields[spec.key] = TextEditingController(text: text);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onKindChanged(SourceKind kind) {
    setState(() {
      _kind = kind;
      _rebuildFieldControllers(kind == widget.initial?.kind ? widget.initial : null);
    });
  }

  Future<void> _save() async {
    final config = <String, dynamic>{};
    for (final spec in fieldsForKind(_kind)) {
      final text = _fields[spec.key]!.text.trim();
      if (spec.isList) {
        final items =
            text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        if (items.isNotEmpty) config[spec.key] = items;
      } else if (text.isNotEmpty) {
        config[spec.key] = text;
      }
    }
    final name = _name.text.trim();
    final source = Source(
      id: widget.initial?.id ?? '',
      kind: _kind,
      name: name.isEmpty ? _kind.label : name,
      config: config,
      enabled: _enabled,
    );
    await ref.read(sourcesControllerProvider.notifier).save(source);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Add source' : 'Edit source'),
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
            decoration: const InputDecoration(labelText: 'Source type'),
            child: DropdownButton<SourceKind>(
              value: _kind,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final kind in SourceKind.values)
                  DropdownMenuItem(value: kind, child: Text(kind.label)),
              ],
              onChanged: (kind) {
                if (kind != null) _onKindChanged(kind);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final spec in fieldsForKind(_kind)) ...[
            TextField(
              controller: _fields[spec.key],
              decoration: InputDecoration(labelText: spec.label),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SwitchListTile(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            title: const Text('Enabled'),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
