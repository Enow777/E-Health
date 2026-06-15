import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global locale notifier. The root app widget listens to this and rebuilds
/// MaterialApp with the new locale whenever the user toggles the language.
final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

/// Called once at app startup to restore the user's last chosen language.
Future<void> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('locale') ?? 'en';
  localeNotifier.value = Locale(code);
}

/// Persists the chosen language and triggers a rebuild of the whole app.
Future<void> setLocale(String languageCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('locale', languageCode);
  localeNotifier.value = Locale(languageCode);
}
