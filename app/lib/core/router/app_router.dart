import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/feed/presentation/feed_screen.dart';
import '../../features/seed/presentation/seed_screen.dart';
import '../../features/settings/domain/llm_provider.dart';
import '../../features/settings/presentation/ai_providers_screen.dart';
import '../../features/settings/presentation/provider_form_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Declarative, deep-linkable navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/feed',
    routes: [
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/seed',
        name: 'seed',
        builder: (context, state) => const SeedScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'ai-providers',
            name: 'ai-providers',
            builder: (context, state) => const AiProvidersScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'provider-edit',
                builder: (context, state) =>
                    ProviderFormScreen(initial: state.extra as LlmProvider?),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
