import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';

class TrendingCarousel extends ConsumerStatefulWidget {
  const TrendingCarousel({super.key});

  @override
  ConsumerState<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends ConsumerState<TrendingCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final trendingAsync = ref.watch(trendingRingtonesProvider);
            
            return trendingAsync.when(
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Container(
                height: 140,
                alignment: Alignment.center,
                child: Text(l10n.errorGeneric(err.toString()), style: const TextStyle(color: Colors.red)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    height: 140,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(l10n.noTrending),
                  );
                }

                // Limit to max 4 items
                final displayItems = items.take(4).toList();

                return Column(
                  children: [
                    CarouselSlider(
                      carouselController: _controller,
                      options: CarouselOptions(
                        height: 140.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      items: displayItems.map((item) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                               onTap: () {
                                  context.push('/detail', extra: {
                                    'list': displayItems,
                                    'index': items.indexOf(item),
                                  });
                               },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(28.0),
                                  image: item['image'] != null && item['image']!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(item['image']!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  gradient: item['image'] != null && item['image']!.isNotEmpty
                                      ? null 
                                      : LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.tertiary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                ),
                                  child: Stack(
                                    children: [
                                      // Gradient overlay for text visibility if image is present
                                      if (item['image'] != null && item['image']!.isNotEmpty)
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28.0),
                                            gradient: LinearGradient(
                                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                        
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] ?? 'Unknown',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  item['duration'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                if (item['isPremium'] == 'true' || item['isPremium'] == true) ...[
                                                   Builder(
                                                     builder: (context) {
                                                       final repo = ref.watch(ringtoneRepositoryProvider);
                                                       final isUserPremium = ref.watch(isPremiumUserProvider);
                                                       final id = item['id']?.toString() ?? '';
                                                       final isUnlocked = repo.isRingtoneUnlocked(id);
                                                       final isLocked = !isUserPremium && !isUnlocked;
                                                       
                                                       if (!isLocked) return const SizedBox.shrink();

                                                       return const Row(
                                                         children: [
                                                           SizedBox(width: 8),
                                                           Icon(
                                                             Icons.workspace_premium,
                                                             color: Colors.amber,
                                                             size: 16,
                                                           ),
                                                         ],
                                                       );
                                                     },
                                                   ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: displayItems.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(_current == entry.key ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 600));
              },
            );
          },
        ),
      ],
    );
  }
}
