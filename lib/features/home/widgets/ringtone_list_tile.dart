import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/core/services/audio_service.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';

class RingtoneListTile extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String author;
  final String duration;
  final String url;
  final bool isPremium;
  final String? image;
  final VoidCallback onTap;

  const RingtoneListTile({
    super.key,
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.url,
    required this.onTap,
    this.isPremium = false,

    this.image,
    this.playlist,
    this.itemIndex,
  });

  final List<Map<String, dynamic>>? playlist;
  final int? itemIndex;

  @override
  ConsumerState<RingtoneListTile> createState() => _RingtoneListTileState();
}

class _RingtoneListTileState extends ConsumerState<RingtoneListTile> {
  bool _isLiked = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final repo = ref.read(ringtoneRepositoryProvider);
    final liked = await repo.isFavorite(widget.id);
    if (mounted) {
      setState(() {
        _isLiked = liked;
        _isLoaded = true;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    // Background sync
    final repo = ref.read(ringtoneRepositoryProvider);
    repo.toggleFavorite(widget.id).then((_) {
       ref.invalidate(favoritesProvider);
    }).catchError((e) {
      // Revert if error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final isUserPremium = ref.watch(isPremiumUserProvider);
    final repo = ref.watch(ringtoneRepositoryProvider);
    final isUnlocked = repo.isRingtoneUnlocked(widget.id);
    final isLocked = widget.isPremium && !isUserPremium && !isUnlocked;

    return StreamBuilder<String?>(
      stream: audioService.currentUrlStream,
      builder: (context, urlSnapshot) {
        final playingUrl = audioService.currentUrl; 
        
        String fixedUrl = widget.url;
        if (fixedUrl.contains('github.com') && fixedUrl.contains('/blob/')) {
           fixedUrl = fixedUrl.replaceFirst('github.com', 'raw.githubusercontent.com');
           fixedUrl = fixedUrl.replaceFirst('/blob/', '/');
        }
        
        final bool isCurrent = (playingUrl == widget.url) || (playingUrl == fixedUrl);
        
        return ListTile(
          onTap: widget.onTap,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isLocked 
                  ? Colors.amber.withOpacity(0.2) 
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(25),
              image: widget.image != null && widget.image!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                 // Dark overlay if image present for contrast (Reduced opacity)
                 if (widget.image != null && widget.image!.isNotEmpty)
                    Container(color: Colors.black26),

                 // Play/Pause Icon Logic
                 StreamBuilder<PlayerState>(
                    stream: audioService.playerStateStream,
                    initialData: audioService.playerState,
                    builder: (context, stateSnapshot) {
                      final playerState = stateSnapshot.data;
                      final bool playing = playerState?.playing ?? false;
                      final processingState = playerState?.processingState;
                      final bool isPlayingThis = isCurrent && playing && (processingState != ProcessingState.completed);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress (if playing)
                          if (isCurrent)
                            StreamBuilder<Duration>(
                              stream: audioService.positionStream,
                              builder: (context, posSnapshot) {
                                final pos = posSnapshot.data?.inMilliseconds ?? 0;
                                return StreamBuilder<Duration?>(
                                  stream: audioService.durationStream,
                                  builder: (context, durSnapshot) {
                                    final total = durSnapshot.data?.inMilliseconds ?? 1;
                                    final double progress = (pos / total).clamp(0.0, 1.0);
                                    
                                    return SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.transparent,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          
                          // Icon / Loading
                          StreamBuilder<bool>(
                            stream: audioService.isLoadingStream,
                            initialData: false,
                            builder: (context, loadingSnap) {
                               if (isPlayingThis && loadingSnap.data == true) {
                                  return const SizedBox(
                                     width: 24, height: 24,
                                     child: CircularProgressIndicator(
                                       strokeWidth: 2,
                                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                     ),
                                  );
                               }
                               return Icon(
                                 isPlayingThis 
                                    ? Icons.pause 
                                    : (isLocked ? Icons.workspace_premium : Icons.play_arrow),
                                 color: isLocked ? Colors.amber : Colors.white,
                                 size: 24,
                               );
                            },
                          ),
                          
                          // Tap to Play (Unlocked) Or Tap to Unlock (Locked)
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (isLocked) {
                                     // Navigate to detail to unlock
                                     widget.onTap(); 
                                  } else {
                                     if (widget.playlist != null && widget.itemIndex != null) {
                                        ref.read(audioServiceProvider).setPlaylist(
                                          widget.playlist!, 
                                          widget.itemIndex!,
                                          isPremiumUser: isUserPremium,
                                          toggleIfSame: true,
                                        );
                                     } else {
                                        ref.read(audioServiceProvider).playRingtone(
                                          widget.url,
                                          id: widget.id,
                                          title: widget.title, 
                                          author: widget.author,
                                          image: widget.image,
                                          toggleIfSame: true,
                                       );
                                     }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.duration,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
             icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
             color: _isLiked ? Colors.red : Theme.of(context).colorScheme.primary,
             onPressed: _toggleFavorite,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
