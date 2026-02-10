import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final _urlController = StreamController<String?>.broadcast();
  final _ringtoneController = StreamController<Map<String, String>?>.broadcast();
  StreamSubscription? _playlistSubscription;
  
  String? _currentUrl;
  Map<String, String>? _currentRingtone;
  
  String? get currentUrl => _currentUrl;
  Map<String, String>? get currentRingtone => _currentRingtone;
  
  Stream<String?> get currentUrlStream => _urlController.stream;
  Stream<Map<String, String>?> get currentRingtoneStream => _ringtoneController.stream;

  AudioService();

  // Helper to fix GitHub links
  String fixUrl(String url) {
    if (url.contains('github.com') && url.contains('/blob/')) {
       url = url.replaceFirst('github.com', 'raw.githubusercontent.com');
       url = url.replaceFirst('/blob/', '/');
    }
    return url;
  }

  String _fixUrl(String url) => fixUrl(url);

  bool isSameRingtone(String? id, String? url) {
    if (_currentRingtone == null) return false;
    
    final currentId = _currentRingtone!['id']?.toString().trim();
    final currentUrl = _currentUrl?.trim();
    
    final targetId = id?.toString().trim();
    final targetUrl = _fixUrl(url ?? '').trim();

    if (targetId != null && currentId == targetId) return true;
    if (targetUrl.isNotEmpty && currentUrl == targetUrl) return true;
    
    return false;
  }

  Future<void> setUrl(String url, {String? id, String? title, String? author, String? image}) async {
    url = _fixUrl(url);
    
    if (_currentUrl != url) {
      _currentUrl = url;
      _urlController.add(url);
    }
    
    try {
      if (title != null || author != null || image != null) {
        _currentRingtone = {
          'id': id ?? url,
          'url': url,
          'title': title ?? 'Unknown Title',
          'author': author ?? 'Unknown Artist',
          'image': image ?? '',
        };
        _ringtoneController.add(_currentRingtone);
      }

      final mediaItem = MediaItem(
        id: url,
        album: "Ringo Ringtones",
        title: title ?? "Unknown Title",
        artist: author ?? "Unknown Artist",
        artUri: image != null && image.isNotEmpty ? Uri.tryParse(image) : null,
      );

      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(url),
        tag: mediaItem,
      ));
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> setPlaylist(List<Map<String, dynamic>> items, int initialIndex, {bool isPremiumUser = false, bool toggleIfSame = false}) async {
      try {
        if (initialIndex >= items.length) return;
        
        final targetUrl = _fixUrl(items[initialIndex]['url'] ?? '');
        
        // SAME SONG Logic: If already playing this URL/ID, handle it
        if (isSameRingtone(items[initialIndex]['id']?.toString(), targetUrl)) {
           if (toggleIfSame && _player.playing) {
              await _player.pause();
           } else if (!_player.playing) {
              if (_player.processingState == ProcessingState.completed) {
                await _player.seek(Duration.zero);
              }
              await _player.play();
           }
           return;
        }

        if (!isPremiumUser) {
           await setRingtone(items[initialIndex].map((k, v) => MapEntry(k, v.toString())));
           await play();
           return;
        }

        final audioSources = items.map((item) {
           final url = _fixUrl(item['url'] ?? '');
           return AudioSource.uri(
             Uri.parse(url),
             tag: MediaItem(
               id: url,
               album: "Ringo Ringtones",
               title: item['title'] ?? "Unknown Title",
               artist: item['author'] ?? "Unknown Artist",
               artUri: item['image'] != null && item['image'].isNotEmpty 
                  ? Uri.tryParse(item['image']) 
                  : null,
             ),
           );
        }).toList();

        final playlist = ConcatenatingAudioSource(children: audioSources);
        
        // Update current URL and Ringtone reference for UI consistency
        if (initialIndex < items.length) {
           final initialItem = items[initialIndex];
           _currentUrl = _fixUrl(initialItem['url'] ?? '');
           _urlController.add(_currentUrl);
           
           _currentRingtone = initialItem.map((k, v) => MapEntry(k, v.toString()));
           _ringtoneController.add(_currentRingtone);
        }

        await _player.setAudioSource(playlist, initialIndex: initialIndex);
        await _player.play();
        
        // Listen to index changes to update current URL and ringtone
        _playlistSubscription?.cancel();
        _playlistSubscription = _player.currentIndexStream.listen((index) {
            if (index != null && index < items.length) {
                final newItem = items[index];
                final newUrl = _fixUrl(newItem['url'] ?? '');
                
                if (_currentUrl != newUrl) {
                    _currentUrl = newUrl;
                    _urlController.add(newUrl);
                    
                    _currentRingtone = newItem.map((k, v) => MapEntry(k, v.toString()));
                    _ringtoneController.add(_currentRingtone);
                }
            }
        });

      } catch (e) {
         print("Error setting playlist: $e");
      }
  }

  Future<void> setRingtone(Map<String, String> ringtone, {bool toggleIfSame = false}) async {
    final url = ringtone['url'];
    if (url == null) return;
    
    final targetUrl = _fixUrl(url);
    if (isSameRingtone(ringtone['id'], targetUrl)) {
       if (toggleIfSame && _player.playing) {
          await _player.pause();
       } else if (!_player.playing) {
          if (_player.processingState == ProcessingState.completed) {
            await _player.seek(Duration.zero);
          }
          await _player.play();
       }
       return;
    }
    
    _currentRingtone = ringtone;
    _ringtoneController.add(ringtone);
    
    await setUrl(
      url, 
      id: ringtone['id'],
      title: ringtone['title'], 
      author: ringtone['author'], 
      image: ringtone['image']
    );
  }

  Future<void> playRingtone(String url, {String? id, String? title, String? author, String? image, bool toggleIfSame = false}) async {
    final targetUrl = _fixUrl(url);

    if (isSameRingtone(id, targetUrl)) {
      if (toggleIfSame && _player.playing) {
        await _player.pause();
      } else if (!_player.playing) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
      return;
    }

    await stop(); 
    _currentRingtone = {
      'id': id ?? url,
      'url': url,
      'title': title ?? 'Unknown Title',
      'author': author ?? 'Unknown Artist',
      'image': image ?? '',
    };
    _ringtoneController.add(_currentRingtone);
    await setUrl(url, id: id, title: title, author: author, image: image); 
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
    } catch (e) {
       // ignore
    }
  }

  Future<void> play() async {
    try {
      if (!_player.playing) {
        await _player.play();
      }
    } catch (e) {
      // Ignore errors during play (e.g. aborted)
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> stop() async {
    _currentUrl = null;
    _currentRingtone = null;
    _urlController.add(null);
    _ringtoneController.add(null);
    _playlistSubscription?.cancel();
    _playlistSubscription = null;
    try {
      await _player.pause();
      await _player.seek(Duration.zero);
      await _player.stop();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> seekToNext({bool isPremiumUser = false}) async {
    if (!isPremiumUser) return; // Restrict for free users
    try {
      if (_player.hasNext) {
        await _player.seekToNext();
      }
    } catch (e) {
       print("Error seekToNext: $e");
    }
  }

  Future<void> seekToPrevious({bool isPremiumUser = false}) async {
    if (!isPremiumUser) return; // Restrict for free users
    try {
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
      }
    } catch (e) {
       print("Error seekToPrevious: $e");
    }
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  PlayerState get playerState => _player.playerState;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get isLoadingStream => _player.processingStateStream.map((state) => 
     state == ProcessingState.loading || state == ProcessingState.buffering
  );

  void dispose() {
    _player.dispose();
    _urlController.close();
  }
}
