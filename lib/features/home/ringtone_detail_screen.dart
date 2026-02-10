import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ringo_ringtones/core/services/audio_service.dart';
import 'package:ringo_ringtones/features/home/widgets/music_visualizer_circle.dart';
import 'package:ringo_ringtones/features/home/widgets/waveform_painter.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:ringo_ringtones/core/services/download_service.dart';
import 'package:ringo_ringtones/core/services/ringtone_manager.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/core/services/ad_service.dart';
import 'dart:async';

class RingtoneDetailScreen extends ConsumerStatefulWidget {
  final Object? ringtoneData;
  const RingtoneDetailScreen({super.key, this.ringtoneData});

  @override
  ConsumerState<RingtoneDetailScreen> createState() => _RingtoneDetailScreenState();
}

class _RingtoneDetailScreenState extends ConsumerState<RingtoneDetailScreen> {
  Map<String, String>? ringtone;
  List<Map<String, String>> _playlist = [];
  int _currentIndex = -1;
  bool _isLiked = false;
  bool _isUnlocked = true;
  bool _isInitialized = false;
  final AdService _adService = adServiceProvider;
  StreamSubscription? _ringtoneSubscription;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    
    // 1. Try passing data directly (for OpenContainer / visual transitions)
    Object? extra = widget.ringtoneData;

    // 2. Fallback to GoRouter state
    if (extra == null) {
       try {
         extra = GoRouterState.of(context).extra;
       } catch (_) {
         // Not in a GoRouter context (e.g. OpenContainer might push via Navigator directly)
       }
    }
    
    if (extra != null) {
      if (extra is Map<String, dynamic>) {
          // Check for new playlist format
          if (extra.containsKey('list') && extra.containsKey('index')) {
              _playlist = (extra['list'] as List).cast<Map<String, String>>();
              _currentIndex = extra['index'] as int;
              if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
                  ringtone = _playlist[_currentIndex];
              }
          } else if (extra is Map<String, String>) {
             // Fallback for direct map passing (legacy or unknown source)
             ringtone = extra;
             _playlist = [ringtone!];
             _currentIndex = 0;
          }
      } 
      
      _isInitialized = true;
      // Initialize player
      _initPlayer();

      // Listen for global ringtone changes to update UI (Next/Previous support)
      _ringtoneSubscription?.cancel();
      _ringtoneSubscription = ref.read(audioServiceProvider).currentRingtoneStream.listen((newRingtone) {
         if (newRingtone != null && mounted) {
            setState(() {
               ringtone = newRingtone;
               // Update index in current playlist
               if (_playlist.isNotEmpty) {
                  final idx = _playlist.indexWhere((item) => item['id'] == newRingtone['id']);
                  if (idx != -1) _currentIndex = idx;
               }
            });
         }
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
     if (ringtone == null) return;
     final id = ringtone!['id'];
     if (id == null) return;
     
     final repo = ref.read(ringtoneRepositoryProvider);
     final liked = await repo.isFavorite(id);
     if (mounted) {
       setState(() {
         _isLiked = liked;
       });
     }
  }

  void _toggleFavorite() {
    if (ringtone == null) return;
    final id = ringtone!['id'];
    if (id == null) return;

    setState(() {
      _isLiked = !_isLiked;
    });
    
    final repo = ref.read(ringtoneRepositoryProvider);
    repo.toggleFavorite(id).then((_) {
       ref.invalidate(favoritesProvider); 
    }).catchError((e) {
      if (mounted) {
        setState(() {
           _isLiked = !_isLiked; // Revert
        });
      }
    });
  }

  Future<void> _initPlayer() async {
    final audioService = ref.read(audioServiceProvider);
    final repo = ref.read(ringtoneRepositoryProvider);
    final isPremium = ref.read(isPremiumUserProvider);
    String? url = ringtone?['url'];
    final id = ringtone?['id'];
    final isPremiumItem = ringtone?['isPremium'] == true || ringtone?['isPremium'].toString() == 'true';
    
    // Check unlock status
    if (id != null) {
      _isUnlocked = !isPremiumItem || repo.isRingtoneUnlocked(id);
    }

    _checkFavoriteStatus();

    if (url != null && url.isNotEmpty) {
      // If not unlocked, we might still want to allow a short preview or just block.
      // User said "Watch Ad to Unlock", so we block full playback if locked.
      // If not unlocked and it is a premium item and user is not premium, block playback.
      if (!_isUnlocked && isPremiumItem && !isPremium) {
        await audioService.stop();
        setState(() {});
        return;
      }

      try {
        // AudioService now handles "Same Song" check internally in setPlaylist/setRingtone
        // Passing toggleIfSame: false ensures it keeps playing if already playing
        if (_playlist.length > 1) {
            final playlistDynamic = _playlist.map((item) => Map<String, dynamic>.from(item)).toList();
            await audioService.setPlaylist(playlistDynamic, _currentIndex, isPremiumUser: isPremium);
        } else {
            if (ringtone != null) {
               await audioService.setRingtone(ringtone!);
            } else {
               await audioService.setUrl(url); // Fallback
            }
        }
      } catch (e) {
        debugPrint("Error loading audio: $e");
      }
    }
  }

  void _playNext() {
    final audioService = ref.read(audioServiceProvider);
    final isPremium = ref.read(isPremiumUserProvider); // Assuming isPremiumUserProvider is defined elsewhere
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length - 1) {
       audioService.seekToNext(isPremiumUser: isPremium);
    }
  }

  void _playPrevious() {
    final audioService = ref.read(audioServiceProvider);
    final isPremium = ref.read(isPremiumUserProvider); // Assuming isPremiumUserProvider is defined elsewhere
    if (_playlist.isNotEmpty && _currentIndex > 0) {
       audioService.seekToPrevious(isPremiumUser: isPremium);
    }
  }

  @override
  void dispose() {
    _ringtoneSubscription?.cancel();
    // Don't stop playback so it continues in background (FAB will handle control)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ringtone == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("No ringtone data provided")),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final title = ringtone!['title'] ?? 'Unknown Title';
    final author = ringtone!['author'] ?? 'Unknown Artist';
    final category = ringtone!['category'] ?? 'General';
    final durationStr = ringtone!['duration'] ?? '';
    final isPremiumItem = ringtone!['isPremium'] == true || 
                          ringtone!['isPremium'].toString().toLowerCase() == 'true';
    final dbTagsStr = ringtone!['tags'] ?? '';
    
    final audioService = ref.watch(audioServiceProvider);
    final isPremium = ref.watch(isPremiumUserProvider);

    // Generate Tags
    List<String> tags = [];
    
    // 1. Add DB Tags
    if (dbTagsStr.isNotEmpty) {
      tags.addAll(dbTagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
    }

    // 2. Fill with Inferred Tags (if space remains)
    if (tags.length < 4) {
       if (category.isNotEmpty && !tags.contains(category)) tags.add(category);
       if (durationStr.isNotEmpty && !tags.contains(durationStr)) tags.add(durationStr);
       final bool showProTag = isPremiumItem && !isPremium && !_isUnlocked;
       final statusTag = showProTag ? "Pro" : "Free";
       if (!tags.contains(statusTag)) tags.add(statusTag);
    }
    
    // Limit to 4 tags
    if (tags.length > 4) tags = tags.take(4).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
         // Do nothing (allow playing in background)
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resono'), 
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
              color: _isLiked ? Colors.red : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Prevent rendering detailed content if constraints are too tight (e.g. during transition glitches)
              if (constraints.maxWidth < 100) {
                 return const SizedBox.shrink(); 
              }
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      // 1. Visualizer Circle (Reduced size)
                      Center(
                        child: Hero(
                          tag: 'floating_player',
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180, 
                                width: 180,
                                child: StreamBuilder<PlayerState>(
                                  stream: audioService.playerStateStream,
                                  initialData: audioService.playerState,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState = playerState?.processingState;
                                    final bool isPlaying = (playerState?.playing ?? false) && (processingState != ProcessingState.completed);
                                    
                                    return MusicVisualizerCircle(
                                      isPlaying: isPlaying,
                                      color: Theme.of(context).colorScheme.primary,
                                    );
                                  },
                                ),
                              ),
                              // Ad-Unlock Overlay
                              if (!_isUnlocked && isPremiumItem && !isPremium)
                                GestureDetector(
                                  onTap: () {
                                    _adService.showRewardedAd(
                                      onUserEarnedReward: () {
                                        final id = ringtone!['id'];
                                        if (id != null) {
                                          ref.read(ringtoneRepositoryProvider).unlockRingtone(id);
                                          setState(() {
                                            _isUnlocked = true;
                                          });
                                          _initPlayer();
                                        }
                                      },
                                      onAdFailed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Ad not ready. Please try again in a moment.")),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                                        const SizedBox(height: 8),
                                        Text(
                                          "WATCH AD\nTO UNLOCK",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      
                      const Spacer(flex: 1),
                      
                      // 2. Title & Author
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Reduced from HeadlineMedium
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Reduced from TitleMedium
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 3. Tags (Max 4)
                      Wrap(
                        spacing: 6, // Reduced spacing
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.1)),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9, // Reduced font size
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              letterSpacing: 0.5
                            )
                          ),
                        )).toList(),
                      ),

                      const Spacer(flex: 2),

                      // 4. Waveform / Progress Slider
                       StreamBuilder<Duration>(
                        stream: audioService.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration?>(
                            stream: audioService.durationStream,
                            builder: (context, durationSnap) {
                               final duration = durationSnap.data ?? const Duration(seconds: 30);
                               double value = position.inMilliseconds.toDouble();
                               double max = duration.inMilliseconds.toDouble();
                               if (value > max) value = max;

                               return Column(
                                 children: [
                                   SizedBox(
                                     height: 30, // Reduced height
                                     width: double.infinity,
                                     child: Stack(
                                       alignment: Alignment.center,
                                       children: [
                                          CustomPaint(
                                            size: const Size(double.infinity, 20),
                                            painter: WaveformPainter(
                                              color: Theme.of(context).colorScheme.primary,
                                              progress: max > 0 ? value / max : 0,
                                            ),
                                          ),
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 20, 
                                              thumbShape: SliderComponentShape.noThumb,
                                              overlayShape: SliderComponentShape.noOverlay,
                                              activeTrackColor: Colors.transparent,
                                              inactiveTrackColor: Colors.transparent,
                                              thumbColor: Colors.transparent, 
                                              overlayColor: Colors.transparent,
                                            ),
                                            child: Slider(
                                              value: value, 
                                              min: 0, 
                                              max: max > 0 ? max : 1.0,
                                              onChanged: (val) {
                                                 audioService.seek(Duration(milliseconds: val.toInt()));
                                              },
                                            ),
                                          ),
                                       ],
                                     ),
                                   ),
                                   // Time Text
                                   Padding(
                                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                          Text(_formatDuration(position), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                                          Text(_formatDuration(duration), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                                       ],
                                     ),
                                   )
                                 ],
                               );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // 5. Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                              IconButton(
                                onPressed: (_currentIndex > 0 && isPremium) ? _playPrevious : null,
                                icon: const Icon(Icons.skip_previous_rounded),
                                iconSize: 32, 
                                color: isPremium 
                                    ? Theme.of(context).colorScheme.onSurface 
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                tooltip: isPremium ? null : "Premium Only",
                              ),
                              const SizedBox(width: 20),
                              StreamBuilder<bool>(
                                stream: audioService.playerStateStream.map((state) => 
                                   state.playing && state.processingState != ProcessingState.completed
                                ), 
                                initialData: false, 
                                builder: (context, snapshot) {
                                  final isPlaying = snapshot.data ?? false;
                                  return Container(
                                    height: 60, width: 60, 
                                    decoration: BoxDecoration(
                                       color: Theme.of(context).colorScheme.primaryContainer,
                                       shape: BoxShape.circle,
                                    ),
                                    child: StreamBuilder<bool>(
                                      stream: audioService.isLoadingStream,
                                      initialData: false,
                                      builder: (context, loadingSnap) {
                                        if (loadingSnap.data == true) {
                                          return const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(strokeWidth: 3),
                                          );
                                        }
                                        return IconButton(
                                           onPressed: _handlePlayPause,
                                           icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                           iconSize: 32, 
                                           color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        );
                                      }
                                    ),
                                  );
                                }
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                onPressed: (_currentIndex >= 0 && _currentIndex < _playlist.length - 1 && isPremium) ? _playNext : null,
                                icon: const Icon(Icons.skip_next_rounded),
                                iconSize: 32,
                                color: isPremium 
                                    ? Theme.of(context).colorScheme.onSurface 
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                tooltip: isPremium ? null : "Premium Only",
                              ),
                        ],
                      ),
                      
                      const Spacer(flex: 2),

                // 6. Action Buttons (Aligned)
                // Primary: Set Ringtone
                SizedBox(
                  width: double.infinity,
                  height: 50, // Reduced from 56
                  child: FilledButton.icon(
                    onPressed: () => _showApplyOptions(context),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(l10n.detailSetRingtone.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 13)),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Secondary: Download | Edit
                Row(
                  children: [
                    // Download Button
                    Expanded(
                      child: SizedBox(
                        height: 50, // Reduced from 56
                        child: OutlinedButton.icon(
                          onPressed: () async {
                              final isPremium = ref.read(isPremiumUserProvider);
                              if (!isPremium && isPremiumItem) {
                                _showPremiumDialog(context, l10n);
                                return;
                              }
                              _downloadRingtone(context, l10n);
                          },
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: Text(l10n.detailDownload, style: const TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                             side: BorderSide(color: Theme.of(context).colorScheme.outline),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Edit Button
                    Expanded(
                      child: SizedBox(
                        height: 50, // Reduced from 56
                        child: OutlinedButton.icon(
                          onPressed: () {
                              final isPremium = ref.read(isPremiumUserProvider);
                              if (!isPremium) {
                                _showPremiumDialog(context, l10n, isEdit: true);
                                return;
                              }
                              _editRingtone(context, l10n);
                          },
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: Text(l10n.detailEdit, style: const TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                             side: BorderSide(color: Theme.of(context).colorScheme.outline),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24), // Bottom Padding
              ],
            ),
          );
        },
      ),
    ),
    ),
    );
  }

  // Helper Methods

  void _handlePlayPause() {
     final audioService = ref.read(audioServiceProvider);
     final isPlaying = audioService.playerState.playing;
     
     if (isPlaying || _isUnlocked) {
       audioService.togglePlayPause();
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Unlock with an ad to play this ringtone")),
       );
     }
  }

  void _showPremiumDialog(BuildContext context, AppLocalizations l10n, {bool isEdit = false}) {
     showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l10n.dialogPremiumTitle),
          content: Text(isEdit ? l10n.dialogEditPremiumContent : l10n.dialogPremiumContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                context.push('/premium');
              },
              child: Text(l10n.btnUpgrade),
            ),
          ],
        ),
      );
  }

  Future<void> _downloadRingtone(BuildContext context, AppLocalizations l10n) async {
      final url = ringtone?['url'];
      final title = ringtone?['title'] ?? 'ringtone';
      if (url == null || url.isEmpty) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgDownloading)));
      
      try {
         final downloadService = ref.read(downloadServiceProvider);
         final fileName = "${title.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp3";
         final tempPath = await downloadService.downloadRingtone(url, fileName);
         
         if (tempPath == null) {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgDownloadFailed)));
             return;
         }

         final ringtoneManager = ref.read(ringtoneManagerProvider);
         final publicPath = await ringtoneManager.saveToMusic(tempPath, title);

         if (mounted) {
           if (publicPath != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${l10n.msgSavedToMusic}: $publicPath")));
           } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgSavedToMusic.replaceAll("Saved", "Failed to save"))));
           }
         }
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
  }

  Future<void> _editRingtone(BuildContext context, AppLocalizations l10n) async {
       final url = ringtone?['url'];
       final title = ringtone?['title'] ?? 'ringtone';
       
       if (url == null || url.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorAudio)));
           return;
       }

       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (c) => const Center(child: CircularProgressIndicator()),
       );

       try {
          final downloadService = ref.read(downloadServiceProvider);
          final path = await downloadService.downloadRingtone(url, "$title.mp3");
          
          if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // Hide loading
              if (path != null) {
                  context.push('/editor', extra: path);
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgDownloadFailed)));
              }
          }
       } catch (e) {
          if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
       }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _handleSetRingtone(String type) async {
    if (ringtone == null) return;
    final l10n = AppLocalizations.of(context)!;
    
    final url = ringtone!['url'];
    final title = ringtone!['title'] ?? 'ringtone';
    
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorAudio)),
      );
      return;
    }

    Navigator.pop(context); // Close bottom sheet
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Download
      final fileName = "${title.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp3";
      final downloadService = ref.read(downloadServiceProvider);
      final localPath = await downloadService.downloadRingtone(url, fileName);

      if (localPath == null) {
        if (mounted) {
           Navigator.pop(context); // Close loading
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(l10n.msgDownloadFailed)),
           );
        }
        return;
      }

      // 2. Set Ringtone
      final ringtoneManager = ref.read(ringtoneManagerProvider);
      bool success = false;
      
      switch (type) {
        case 'ringtone':
          success = await ringtoneManager.setRingtone(localPath);
          break;
        case 'notification':
          success = await ringtoneManager.setNotification(localPath);
          break;
        case 'alarm':
          success = await ringtoneManager.setAlarm(localPath);
          break;
        case 'contact':
           // Pick contact
           if (await FlutterContacts.requestPermission()) {
               final contact = await FlutterContacts.openExternalPick();
               if (contact != null) {
                   String contactUri = "content://com.android.contacts/contacts/${contact.id}";
                   success = await ringtoneManager.setRingtoneForContact(localPath, contactUri);
               } else {
                 if (mounted) Navigator.pop(context); // Close loading if cancelled
                 return; 
               }
           } else {
              if (mounted) {
                 Navigator.pop(context); // Close loading
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.permissionContact)),
                 );
              }
              return;
           }
          break;
      }

      if (mounted) {
        Navigator.pop(context);
        if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('${l10n.detailSetSuccess} $type')),
           );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(l10n.detailSetFailed)),
           );
        }
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showApplyOptions(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    showModalBottomSheet(
      context: parentContext,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.call),
                title: Text(l10n.setAsRingtone),
                onTap: () => _handleSetRingtone('ringtone'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(l10n.setAsNotification),
                onTap: () => _handleSetRingtone('notification'),
              ),
              ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(l10n.setAsAlarm),
                onTap: () => _handleSetRingtone('alarm'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.setForContact),
                onTap: () => _handleSetRingtone('contact'),
              ),
            ],
          ),
        );
      },
    );
  }
}
