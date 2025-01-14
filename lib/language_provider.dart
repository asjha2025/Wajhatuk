import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('ar'); // Default language is Arabic

  Locale get locale => _locale;

  void switchLanguage() {
    if (_locale.languageCode == 'ar') {
      _locale = Locale('en'); // Switch to English
    } else {
      _locale = Locale('ar'); // Switch to Arabic
    }
    notifyListeners();
  }
}
