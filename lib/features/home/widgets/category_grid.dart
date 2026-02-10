import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';

class CategoryGrid extends ConsumerStatefulWidget {
  const CategoryGrid({super.key});

  @override
  ConsumerState<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends ConsumerState<CategoryGrid> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.categoriesTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            
            return categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
              ),
              data: (categories) {
                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text(l10n.noCategories),
                  );
                }

                // Limit categories to 6 if not expanded
                final visibleCategories = _isExpanded 
                    ? categories 
                    : categories.take(6).toList();

                return Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: visibleCategories.length,
                      itemBuilder: (context, index) {
                        final cat = visibleCategories[index];
                        final name = cat['name'] ?? 'Unknown';
                        final imageUrl = cat['image'] ?? '';

                        return Card(
                          elevation: 0, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              context.push('/category/$name');
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(color: Theme.of(context).colorScheme.primary.withOpacity(0.3));
                                    },
                                  )
                                else
                                  Container(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),

                                Center(
                                  child: Text(
                                    name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 50 * index)).scale(duration: const Duration(milliseconds: 400));
                      },
                    ),
                    if (categories.length > 6)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_isExpanded ? l10n.showLess : l10n.seeMore),
                              const SizedBox(width: 4),
                              Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
