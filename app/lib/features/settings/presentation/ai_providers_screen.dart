import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../domain/llm_provider.dart';
import 'llm_providers_controller.dart';

class AiProvidersScreen extends ConsumerWidget {
  const AiProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(llmProvidersControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Providers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/ai-providers/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: providers.isEmpty
          ? const Center(child: Text('No providers yet. Tap Add to create one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: providers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => _ProviderCard(provider: providers[i]),
            ),
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  const _ProviderCard({required this.provider});

  final LlmProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(llmProvidersControllerProvider.notifier);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Flexible(
                  child: Text(provider.name, overflow: TextOverflow.ellipsis),
                ),
                if (provider.isDefault) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const _DefaultBadge(),
                ],
              ],
            ),
            subtitle: Text('${provider.type.label} · ${provider.authMethod.label}'),
            onTap: () =>
                context.push('/settings/ai-providers/edit', extra: provider),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'default':
                    controller.setDefault(provider.id);
                  case 'test':
                    _showTestResult(context);
                  case 'delete':
                    controller.remove(provider.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'default', child: Text('Set as default')),
                PopupMenuItem(value: 'test', child: Text('Test connection')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
          SwitchListTile(
            value: provider.enabled,
            onChanged: (_) => controller.toggleEnabled(provider.id),
            title: const Text('Enabled'),
            dense: true,
          ),
        ],
      ),
    );
  }

  void _showTestResult(BuildContext context) {
    // Mock connectivity check; the real impl round-trips a tiny prompt.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test OK · simulated 240 ms')),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(40),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: const Text(
        'DEFAULT',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
