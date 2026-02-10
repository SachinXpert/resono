import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'widgets/ringtone_list_tile.dart';
import 'package:ringo_ringtones/features/home/widgets/floating_music_player.dart';

class CategoryListingScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryListingScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(ringtoneRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // Localize "Latest" if applicable
    String displayTitle = categoryName;
    if (categoryName == 'Latest') {
      displayTitle = l10n.latestTitle;
    } else if (categoryName == 'Trending Now') { // Just in case
       displayTitle = l10n.trendingTitle;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final ringtonesAsync = ref.watch(categoryRingtonesProvider(categoryName)); // Use original for API/Query
          
          return ringtonesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
            data: (ringtones) {
              if (ringtones.isEmpty) {
                 return Center(child: Text(l10n.noResults));
              }

              return ListView.separated(
                itemCount: ringtones.length,
                padding: const EdgeInsets.symmetric(vertical: 16),
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final ringtone = ringtones[index];
                  final isPremium = ringtone['isPremium'] == true || ringtone['isPremium'].toString() == 'true';
                  return RingtoneListTile(
                    id: ringtone['id'] ?? '',
                    title: ringtone['title'] ?? 'Unknown',
                    author: ringtone['author'] ?? 'Unknown Artist',
                    duration: ringtone['duration'] ?? '0:30',
                    url: ringtone['url'] ?? '',
                    isPremium: isPremium,
                    image: ringtone['image'],
                    playlist: ringtones,
                    itemIndex: index,
                    onTap: () {
                       context.push('/detail', extra: {
                         'list': ringtones,
                         'index': index,
                       });
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
