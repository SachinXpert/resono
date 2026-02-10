import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/features/home/widgets/ringtone_list_tile.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';

class RingtonesScreen extends ConsumerWidget {
  const RingtonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using latestRingtones as the main "All Ringtones" list for now
    // Ideally this would be a specific 'allRingtones' provider if distinct
    final ringtonesAsync = ref.watch(latestRingtonesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ringtonesTitle),
      ),
      body: ringtonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (ringtones) {
          if (ringtones.isEmpty) {
            return Center(child: Text(l10n.noResults));
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(latestRingtonesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: ringtones.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final item = ringtones[index];
                final isPremium = item['isPremium'] == true || item['isPremium'].toString() == 'true';
                
                return RingtoneListTile(
                  id: item['id'] ?? '',
                  title: item['title'] ?? 'Unknown',
                  author: item['author'] ?? 'Unknown Artist',
                  duration: item['duration'] ?? '',
                  url: item['url'] ?? '',
                  isPremium: isPremium,
                  image: item['image'],
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
            ),
          );
        },
      ),
    );
  }
}
