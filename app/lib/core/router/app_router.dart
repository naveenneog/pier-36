import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/feed/presentation/feed_screen.dart';
import '../../features/seed/presentation/seed_screen.dart';

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
    ],
  );
});
