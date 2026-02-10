import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/features/home/widgets/ringtone_list_tile.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';

class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.songsTitle),
      ),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (songs) {
          if (songs.isEmpty) {
            return Center(child: Text(l10n.noSongs));
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(songsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: songs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final song = songs[index];
                return RingtoneListTile(
                  id: song['id'] ?? '',
                  title: song['title'] ?? 'Unknown',
                  author: song['author'] ?? 'Unknown Artist',
                  duration: song['duration'] ?? '',
                  url: song['url'] ?? '',
                  image: song['image'],
                  onTap: () {
                    context.push('/detail', extra: song);
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
