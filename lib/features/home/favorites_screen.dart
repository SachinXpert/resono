import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import '../../data/repositories/ringtone_repository.dart';
import 'widgets/ringtone_list_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(ringtoneRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final favoritesAsync = ref.watch(favoritesProvider);
          
          return favoritesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
            data: (favorites) {
              if (favorites.isEmpty) {
                return Center(child: Text(l10n.noFavorites));
              }
              return ListView.separated(
                itemCount: favorites.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final tone = favorites[index];
                  return RingtoneListTile(
                     id: tone['id'] ?? '',
                     title: tone['title'] ?? 'Unknown',
                     author: tone['author'] ?? 'Unknown',
                     duration: tone['duration'] ?? '0:30',
                     url: tone['url'] ?? '',
                     image: tone['image'],
                     playlist: favorites,
                     itemIndex: index,
                     onTap: (){
                       // Navigate to detail
                       GoRouter.of(context).push('/detail', extra: tone);
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
