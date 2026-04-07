import 'package:flutter/material.dart';

import 'storage_service.dart';

class AppThemeService {
  static final ValueNotifier<ThemeMode> currentMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final storedMode = await StorageService.getThemeMode();
    currentMode.value = storedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    if (currentMode.value == mode) {
      return;
    }

    await StorageService.setThemeMode(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    currentMode.value = mode;
  }

  static bool get isDarkMode => currentMode.value == ThemeMode.dark;
}
