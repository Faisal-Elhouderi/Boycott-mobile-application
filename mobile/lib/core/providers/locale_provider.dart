import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar'));

  Future<void> setLocale(Locale locale) async {
    state = locale;
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    setLocale(newLocale);
  }
}
