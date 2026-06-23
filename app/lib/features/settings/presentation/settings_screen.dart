import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
