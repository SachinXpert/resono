import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/features/home/widgets/ringtone_list_tile.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/features/home/widgets/floating_music_player.dart';

class PremiumContentScreen extends ConsumerStatefulWidget {
  const PremiumContentScreen({super.key});

  @override
  ConsumerState<PremiumContentScreen> createState() => _PremiumContentScreenState();
}

class _PremiumContentScreenState extends ConsumerState<PremiumContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resono'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: "Ringtones"),
            Tab(text: l10n.songsTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRingtonesTab(context, ref, l10n),
          _buildSongsTab(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildRingtonesTab(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    // Reusing logic from LatestRingtonesList but showing full list if possible
    // Using trendingRingtonesProvider or latestRingtonesProvider
    // Let's use latestRingtonesProvider for variety or add a new provider if needed.
    // Ideally we'd show a full grid or list. Let's stick to list for consistency.
    final ringtonesAsync = ref.watch(latestRingtonesProvider);

    return ringtonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(l10n.errorGeneric(err.toString()))),
      data: (items) {
          // Filter for premium items
          final premiumItems = items.where((item) => item['isPremium'] == true || item['isPremium'].toString() == 'true').toList();

          if (premiumItems.isEmpty) {
             return Center(child: Text(l10n.noLatestRingtones));
          }
          return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: premiumItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                  final item = premiumItems[index];
                  final isPremium = item['isPremium'] == true || item['isPremium'].toString() == 'true';
                  
                  return RingtoneListTile(
                      id: item['id'] ?? '',
                      title: item['title'] ?? 'Unknown',
                      author: item['author'] ?? 'Unknown Artist',
                      duration: item['duration'] ?? '0:30',
                      url: item['url'] ?? '',
                      isPremium: false, // Don't show badge
                      image: item['image'],
                      onTap: () => context.push('/detail', extra: item), // Always open detail
                  );
              },
          );
      },
    );
  }

  Widget _buildSongsTab(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
      final songsAsync = ref.watch(songsProvider);

      return songsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(l10n.errorGeneric(err.toString()))),
          data: (songs) {
              // Filter for premium songs
          final premiumSongs = songs.where((song) => song['isPremium'] == true || song['isPremium'].toString() == 'true').toList();

          if (premiumSongs.isEmpty) {
              return Center(child: Text(l10n.noSongs));
          }
          return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: premiumSongs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                  final song = premiumSongs[index];
                      return RingtoneListTile(
                          id: song['id'] ?? '',
                          title: song['title'] ?? 'Unknown',
                          author: song['author'] ?? 'Unknown Artist',
                          duration: song['duration'] ?? '',
                          url: song['url'] ?? '',
                          isPremium: false,
                          image: song['image'],
                          onTap: () => context.push('/detail', extra: song),
                      );
                  },
              );
          },
      );
  }
}
