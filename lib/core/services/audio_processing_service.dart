import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProcessingServiceProvider = Provider<AudioProcessingService>((ref) {
  return AudioProcessingService();
});

class AudioProcessingService {
  static const platform = MethodChannel('ringo/ringtone_manager');

  Future<String?> trimAudio({
    required String inputPath,
    required String outputPath,
    required double start,
    required double end,
    bool fade = false, // Ignored in native simple trim
  }) async {
    try {
      final String? result = await platform.invokeMethod('trimAudio', {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'start': start,
        'end': end,
      });
      return result;
    } on PlatformException catch (e) {
      print("Native Trim Failed: ${e.message}");
      return null;
    } catch (e) {
      print("Trim Error: $e");
      return null;
    }
  }
}
