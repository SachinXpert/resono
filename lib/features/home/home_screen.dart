import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/trending_carousel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/category_grid.dart';
import 'widgets/latest_ringtones_list.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';

import 'package:ringo_ringtones/l10n/app_localizations.dart';

import 'widgets/floating_music_player.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ringo_ringtones/core/widgets/banner_ad_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Row(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'search_box',
                    child: Material(
                      type: MaterialType.transparency,
                      child: GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.searchHint,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications',
                  ),
                ),
              ],
            ),
            floating: true,
            pinned: true,
            toolbarHeight: 70,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          const SliverToBoxAdapter(
            child: TrendingCarousel(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                   Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          title: "Resono", 
                          icon: Icons.workspace_premium_rounded,
                          colors: const [Color(0xFFFFD700), Color(0xFFFFA500)],
                          onTap: () {
                            final isPremium = ref.read(isPremiumUserProvider);
                            if (isPremium) {
                              context.push('/premium-content');
                            } else {
                              context.push('/premium');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          title: "Cutter",
                          icon: Icons.content_cut_rounded,
                          colors: const [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          onTap: () => context.push('/editor'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          title: "Favorites",
                          icon: Icons.favorite_rounded,
                          colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          onTap: () => context.push('/favorites'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Banner Ad
                  if (!ref.watch(isPremiumUserProvider))
                    const Center(child: BannerAdWidget()),
                ],
              ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 600)),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          const SliverToBoxAdapter(
            child: LatestRingtonesList(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          const SliverToBoxAdapter(
            child: CategoryGrid(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding
          ),
        ],
      ),
    );
  }
  }

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20), 
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
