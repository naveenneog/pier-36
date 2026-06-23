import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../domain/source.dart';
import 'sources_controller.dart';

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/sources/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: sources.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Failed to load sources: $error'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Text('No sources yet. Tap Add to follow GitHub, arXiv, RSS, Reddit…'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _SourceCard(source: items[i]),
              ),
      ),
    );
  }
}

class _SourceCard extends ConsumerWidget {
  const _SourceCard({required this.source});

  final Source source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sourcesControllerProvider.notifier);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(source.name, overflow: TextOverflow.ellipsis),
            subtitle: Text('${source.kind.label} · ${_summary(source)}'),
            onTap: () => context.push('/settings/sources/edit', extra: source),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') controller.remove(source.id);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
          SwitchListTile(
            value: source.enabled,
            onChanged: (_) => controller.toggleEnabled(source),
            title: const Text('Enabled'),
            dense: true,
          ),
        ],
      ),
    );
  }

  String _summary(Source source) {
    final parts = <String>[];
    source.config.forEach((key, value) {
      parts.add(value is List ? '$key: ${value.join(', ')}' : '$key: $value');
    });
    return parts.isEmpty ? 'no config' : parts.join(' · ');
  }
}
