import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/features/home/widgets/ringtone_list_tile.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _query = query;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _query = query;
    });

    try {
      final repo = ref.read(ringtoneRepositoryProvider);
      // Capitalize first letter to match Firestore usually (if case sensitive)
      // Note: Firestore text search is limited. If data is "Iphone", searching "iphone" might fail depending on index.
      // For now we pass as is or capitalize first.
      // Let's pass as is.
      final results = await repo.searchRingtones(query);
      
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() {
           _isLoading = false;
           _results = [];
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
           // Hero Search Bar Area
           Hero(
             tag: 'search_box',
             child: Material(
               type: MaterialType.transparency,
               child: Container(
                  height: 60, // Slightly taller for better touch area
                  margin: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8), // Top margin for StatusBar
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: l10n.searchHint,
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                             _performSearch(val);
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        ),
                    ],
                  ),
               ),
             ),
           ),
           // Results
           Expanded(
             child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              _query.isEmpty ? l10n.typeToSearch : l10n.noResults,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final ringtone = _results[index];
                          final bool isPremium = ringtone['isPremium'] == 'true' || ringtone['isPremium'] == true;
                          
                          return RingtoneListTile(
                            id: ringtone['id'] ?? '',
                            title: ringtone['title'] ?? 'Unknown',
                            author: ringtone['author'] ?? 'Unknown',
                            duration: ringtone['duration'] ?? '',
                            url: ringtone['url'] ?? '',
                            isPremium: isPremium,
                            image: ringtone['image'],
                            onTap: () {
                               if (isPremium) {
                                   context.push('/premium');
                               } else {
                                   context.push('/detail', extra: ringtone);
                               }
                            },
                          );
                        },
                      ),
           ),
        ],
      ),
    );
  }
}
