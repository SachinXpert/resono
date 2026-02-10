import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/songs_screen.dart';
import '../features/home/category_listing_screen.dart';
import '../features/home/ringtone_detail_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/editor/editor_screen.dart'; 
import '../features/notifications/notification_screen.dart';
import '../features/premium/premium_subscription_screen.dart';
import '../features/premium/premium_content_screen.dart';
import '../features/home/ringtones_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/about_us_screen.dart';
import 'package:ringo_ringtones/core/services/audio_service.dart';
import '../features/home/widgets/floating_music_player.dart';
// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute( // Global FAB Wrapper
        builder: (context, state, child) {
          return GlobalFABWrapper(child: child);
        },
        routes: [
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) {
              return ScaffoldWithNavBar(child: child);
            },
            routes: [
              // TAB 0: Home
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              // TAB 1: Ringtones
              GoRoute(
                path: '/ringtones',
                builder: (context, state) => const RingtonesScreen(),
              ),
              // TAB 2: Songs
              GoRoute(
                path: '/songs',
                builder: (context, state) => const SongsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/detail', 
            builder: (context, state) => const RingtoneDetailScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/editor',
            builder: (context, state) {
               final path = state.extra as String?;
               return EditorScreen(initialFilePath: path);
            },
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/premium',
            builder: (context, state) => const PremiumSubscriptionScreen(),
          ),
          GoRoute(
            path: '/premium-content',
            builder: (context, state) => const PremiumContentScreen(),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const SearchScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutUsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/category/:name',
            builder: (context, state) {
               final name = state.pathParameters['name']!;
               return CategoryListingScreen(categoryName: name);
            },
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        height: 65,
        margin: EdgeInsets.fromLTRB(100, 0, 100, 20 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, ref, 0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(context, ref, 1, Icons.queue_music_outlined, Icons.queue_music, 'Ringtones'),
              _buildNavItem(context, ref, 2, Icons.library_music_outlined, Icons.library_music, 'Songs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, IconData icon, IconData selectedIcon, String label) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isSelected = index == selectedIndex;
    
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/ringtones');
            break;
          case 2:
            context.go('/songs');
            break;
        }
      },
      child: Container(
        color: Colors.transparent, 
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            isSelected ? selectedIcon : icon,
            size: 26,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer 
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/ringtones')) {
      return 1;
    }
    if (location.startsWith('/songs')) {
      return 2;
    }
    // Let's return -1 if possible or let it be.
    return 0; 
  }
}

class GlobalFABWrapper extends ConsumerWidget {
  final Widget child;
  const GlobalFABWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine if we should show the FAB based on the current route
    final state = GoRouterState.of(context);
    final location = state.uri.path;
    
    // Don't show FAB on Detail Screen or Editor Screen
    final bool hideFAB = location.startsWith('/detail') || location.startsWith('/editor');
    
    // If it's one of the main tabs, it has the floating navbar, so we need extra bottom padding
    final bool hasNavbar = location.startsWith('/home') || 
                           location.startsWith('/ringtones') || 
                           location.startsWith('/songs');

    return Scaffold(
      body: child,
      floatingActionButton: hideFAB ? null : Padding(
        padding: EdgeInsets.only(bottom: hasNavbar ? (85.0 + MediaQuery.of(context).padding.bottom) : 0.0),
        child: const FloatingMusicPlayer(),
      ),
    );
  }
}
