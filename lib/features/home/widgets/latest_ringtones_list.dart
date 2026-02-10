import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/features/home/widgets/ringtone_list_tile.dart';

class LatestRingtonesList extends ConsumerWidget {
  const LatestRingtonesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(ringtoneRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.latestTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/category/Latest'); 
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2), // Space between text and underline
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.0, 
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.seeMore,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final latestAsync = ref.watch(latestRingtonesProvider);
            
            return latestAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(l10n.noLatestRingtones),
                  );
                }
                
                // Limit to 6 items
                final displayItems = items.take(5).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: displayItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final item = displayItems[index];
                    final isPremium = item['isPremium'] == true || item['isPremium'].toString() == 'true';

                    return RingtoneListTile(
                      id: item['id'] ?? '',
                      title: item['title'] ?? 'Unknown',
                      author: item['author'] ?? 'Unknown Artist',
                      duration: item['duration'] ?? '0:30',
                      url: item['url'] ?? '',
                      isPremium: isPremium,
                      image: item['image'],
                      playlist: displayItems,
                      itemIndex: index,
                      onTap: () {
                         context.push('/detail', extra: {
                          'list': displayItems,
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
      ],
    );
  }
}
