import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for SharedPreferences
const String kThemeModeKey = 'theme_mode';
const String kDynamicColorKey = 'use_dynamic_color';

class ThemeState {
  final ThemeMode themeMode;
  final bool useDynamicColor;

  ThemeState({this.themeMode = ThemeMode.system, this.useDynamicColor = true});

  ThemeState copyWith({ThemeMode? themeMode, bool? useDynamicColor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences prefs;

  ThemeNotifier(this.prefs) : super(ThemeState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final themeIndex = prefs.getInt(kThemeModeKey);
    final useDynamic = prefs.getBool(kDynamicColorKey) ?? true;

    ThemeMode mode = ThemeMode.system;
    if (themeIndex != null) {
      mode = ThemeMode.values[themeIndex];
    }

    state = ThemeState(themeMode: mode, useDynamicColor: useDynamic);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    prefs.setInt(kThemeModeKey, mode.index);
  }

  void toggleDynamicColor(bool value) {
    state = state.copyWith(useDynamicColor: value);
    prefs.setBool(kDynamicColorKey, value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // We need to access SharedPreferences. 
  // Ideally, SharedPreferences should be provided via a provider or passed in main. 
  // For now, we'll assume it's initialized in main and we can pass it, 
  // BUT StateNotifier provider build can't async await.
  // Better pattern: use FutureProvider or initialized provider override in main.
  throw UnimplementedError('themeProvider must be overridden in main');
});
