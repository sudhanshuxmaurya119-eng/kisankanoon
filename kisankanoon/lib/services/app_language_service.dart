import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class SupportedLanguage {
  final String code;
  final String name;

  const SupportedLanguage({
    required this.code,
    required this.name,
  });
}

class AppLanguageService {
  static final ValueNotifier<String> currentCode = ValueNotifier<String>('hi');

  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'hi', name: 'हिंदी'),
    SupportedLanguage(code: 'en', name: 'English'),
    SupportedLanguage(code: 'mr', name: 'मराठी'),
    SupportedLanguage(code: 'pa', name: 'ਪੰਜਾਬੀ'),
    SupportedLanguage(code: 'te', name: 'తెలుగు'),
    SupportedLanguage(code: 'bn', name: 'বাংলা'),
  ];

  static Future<void> load() async {
    currentCode.value = await StorageService.getLang();
  }

  static Future<void> setLanguage(String code) async {
    if (currentCode.value == code) return;
    await StorageService.setLang(code);
    currentCode.value = code;
  }

  static String languageName(String code) {
    for (final language in supportedLanguages) {
      if (language.code == code) {
        return language.name;
      }
    }
    return supportedLanguages.first.name;
  }
}
