import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;

final ringtoneManagerProvider = Provider<RingtoneManager>((ref) {
  return RingtoneManager();
});

class RingtoneManager {
  static const platform = MethodChannel('ringo/ringtone_manager');

  Future<bool> setRingtone(String filePath) async {
    try {
      final bool result = await platform.invokeMethod('setRingtone', {'path': filePath, 'type': 'ringtone'});
      return result;
    } on PlatformException catch (e) {
      print("Failed to set ringtone: '${e.message}'.");
      return false;
    }
  }

  Future<bool> setNotification(String filePath) async {
    try {
      final bool result = await platform.invokeMethod('setRingtone', {'path': filePath, 'type': 'notification'});
      return result;
    } on PlatformException catch (e) {
      print("Failed to set notification: '${e.message}'.");
      return false;
    }
  }

  Future<bool> setAlarm(String filePath) async {
    try {
      final bool result = await platform.invokeMethod('setRingtone', {'path': filePath, 'type': 'alarm'});
      return result;
    } on PlatformException catch (e) {
      print("Failed to set alarm: '${e.message}'.");
      return false;
    }
  }

  Future<bool> setRingtoneForContact(String filePath, String contactUri) async {
    try {
      final bool result = await platform.invokeMethod('setRingtoneForContact', {'path': filePath, 'contactUri': contactUri});
      return result;
    } on PlatformException catch (e) {
      print("Failed to set ringtone for contact: '${e.message}'.");
      return false;
    }
  }

  Future<String?> saveToMusic(String filePath, String title) async {
    try {
      final String? result = await platform.invokeMethod('saveToMusic', {'path': filePath, 'title': title});
      return result;
    } on PlatformException catch (e) {
      print("Failed to save to music: '${e.message}'.");
      return null;
    }
  }
}
