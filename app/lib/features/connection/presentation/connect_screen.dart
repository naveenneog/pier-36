import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../domain/supabase_config.dart';
import 'connection_controller.dart';

/// Click-through setup: paste the Supabase URL + anon key once; it's stored
/// locally and auto-reconnects on next launch.
class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _url = TextEditingController();
  final _anon = TextEditingController();
  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _url.dispose();
    _anon.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final url = _url.text.trim();
    final anon = _anon.text.trim();
    if (url.isEmpty || anon.isEmpty) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(connectionControllerProvider.notifier)
          .save(SupabaseConfig(url: url, anonKey: anon));
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Connected to Supabase')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  Future<void> _disconnect() async {
    await ref.read(connectionControllerProvider.notifier).disconnect();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionControllerProvider);
    if (!_prefilled && connection.config != null) {
      _url.text = connection.config!.url;
      _anon.text = connection.config!.anonKey;
      _prefilled = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Supabase')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text(
            'Paste your Supabase project URL and anon key. '
            'Find them in Project Settings -> API.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Project URL',
              hintText: 'https://YOUR-REF.supabase.co',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _anon,
            decoration: const InputDecoration(
              labelText: 'Anon / publishable key',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save & Connect'),
          ),
          if (connection.isConnected) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _disconnect,
              child: const Text('Disconnect'),
            ),
          ],
        ],
      ),
    );
  }
}
