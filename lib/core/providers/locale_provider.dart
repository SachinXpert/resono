import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  throw UnimplementedError('Initialize with override');
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(null) {
    _initLocale();
  }

  void _initLocale() {
    final String? languageCode = _prefs.getString('language_code');
    if (languageCode != null) {
      state = Locale(languageCode);
    }
    // If null, state remains null (System default)
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale != null) {
      await _prefs.setString('language_code', locale.languageCode);
    } else {
      await _prefs.remove('language_code');
    }
  }
}
