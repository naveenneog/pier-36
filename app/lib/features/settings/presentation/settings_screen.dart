import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../connection/presentation/connection_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final host = connection.config == null
        ? null
        : Uri.tryParse(connection.config!.url)?.host;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Providers'),
            subtitle: const Text('Configure the LLM gateway (Azure, OpenAI, Ollama…)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/ai-providers'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Backend connection'),
            subtitle: Text(
              connection.isConnected
                  ? 'Connected: ${host ?? connection.config!.url}'
                  : 'Not connected (demo mode)',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/connection'),
          ),
          if (connection.isConnected)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                auth.signedIn
                    ? 'Signed in${auth.email != null ? ' as ${auth.email}' : ''}'
                    : 'Not signed in',
              ),
              trailing: auth.signedIn
                  ? TextButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      child: const Text('Sign out'),
                    )
                  : FilledButton.icon(
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .signInWithGitHub(),
                      icon: const Icon(Icons.code),
                      label: const Text('Continue with GitHub'),
                    ),
            ),
        ],
      ),
    );
  }
}
