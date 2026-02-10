import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ringo_ringtones/core/services/audio_service.dart';
import 'package:ringo_ringtones/features/home/widgets/music_visualizer_circle.dart';
import 'package:animations/animations.dart';
import '../ringtone_detail_screen.dart';

class FloatingMusicPlayer extends ConsumerStatefulWidget {
  const FloatingMusicPlayer({super.key});

  @override
  ConsumerState<FloatingMusicPlayer> createState() => _FloatingMusicPlayerState();
}

class _FloatingMusicPlayerState extends ConsumerState<FloatingMusicPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(seconds: 4),
       vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);

    return StreamBuilder<Map<String, String>?>(
      stream: audioService.currentRingtoneStream,
      initialData: audioService.currentRingtone,
      builder: (context, snapshot) {
        final ringtone = snapshot.data;
        if (ringtone == null) return const SizedBox.shrink();

        // Premium Hero Animation
        return GestureDetector(
          onTap: () {
            context.push('/detail', extra: ringtone);
          },
          child: Hero(
            tag: 'floating_player',
            child: StreamBuilder<PlayerState>(
              stream: audioService.playerStateStream,
              initialData: audioService.playerState,
              builder: (context, playerSnapshot) {
                 final playerState = playerSnapshot.data;
                 final processingState = playerState?.processingState;
                 final isPlaying = (playerState?.playing ?? false) && (processingState != ProcessingState.completed);
                 
                 if (isPlaying) {
                   _controller.repeat();
                 } else {
                   _controller.stop();
                 }

                 return RotationTransition(
                   turns: _controller,
                   child: Container(
                     height: 56,
                     width: 56,
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primaryContainer,
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.2),
                           blurRadius: 8,
                           offset: const Offset(0, 4),
                         )
                       ],
                       border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                       ),
                     ),
                     child: StreamBuilder<bool>(
                       stream: audioService.isLoadingStream,
                       initialData: false,
                       builder: (context, loadingSnap) {
                         if (loadingSnap.data == true) {
                           return const Padding(
                             padding: EdgeInsets.all(12.0),
                             child: CircularProgressIndicator(
                               strokeWidth: 2,
                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                             ),
                           );
                         }
                         return Icon(
                            Icons.music_note_rounded,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                         );
                       }
                     ),
                   ),
                 );
              },
            ),
          ),
        );
      },
    );
  }
}
