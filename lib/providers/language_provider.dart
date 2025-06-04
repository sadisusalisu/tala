import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;
  bool get isHausa => _currentLanguage == 'ha';
  bool get isEnglish => _currentLanguage == 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (language != _currentLanguage) {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      notifyListeners();
    }
  }

  String translate(String key) {
    final translations = {
      'en': {
        'app_name': 'TALA',
        'stories': 'Stories',
        'favorites': 'Favorites',
        'settings': 'Settings',
        'folktales': 'Folktales',
        'religious': 'Religious',
        'bedtime': 'Bedtime',
        'educational': 'Educational',
        'listen': 'Listen',
        'read': 'Read',
        'play': 'Play',
        'pause': 'Pause',
        'stop': 'Stop',
        'add_to_favorites': 'Add to Favorites',
        'remove_from_favorites': 'Remove from Favorites',
        'download_offline': 'Download for Offline',
        'login_required': 'Login Required',
        'login_message': 'Register to save your favorite stories and access them offline.',
        'login': 'Login',
        'register': 'Register',
        'email': 'Email',
        'password': 'Password',
        'language': 'Language',
        'english': 'English',
        'hausa': 'Hausa',
        'sign_out': 'Sign Out',
        'guest_user': 'Guest User',
        'no_stories': 'No stories available',
        'no_favorites': 'No favorite stories yet',
        'loading': 'Loading...',
        'error': 'Something went wrong',
        'try_again': 'Try Again',
        'cancel': 'Cancel',
        'ok': 'OK',
        'all_categories': 'All',
        'dark_mode': 'Dark Mode',
        'about': 'About',
        'version': 'Version',
        'continue_as_guest': 'Continue as Guest',
        'sync_favorites': 'Sync Favorites',
        'offline_mode': 'Offline Mode',
        'network_error': 'Network Error',
        'retry': 'Retry',
        'welcome': 'Welcome to TALA',
        'welcome_message': 'Discover amazing stories in Hausa and English',
      },
      'ha': {
        'app_name': 'TALA',
        'stories': 'Labarai',
        'favorites': 'Abubuwan da na fi so',
        'settings': 'Saitunan',
        'folktales': 'Tatsuniyoyi',
        'religious': 'Addini',
        'bedtime': 'Lokacin barci',
        'educational': 'Ilimi',
        'listen': 'Saurara',
        'read': 'Karanta',
        'play': 'Kunna',
        'pause': 'Tsayar',
        'stop': 'Dakatar',
        'add_to_favorites': 'Saka cikin abubuwan da na fi so',
        'remove_from_favorites': 'Cire daga abubuwan da na fi so',
        'download_offline': 'Sauke don amfani ba tare da intanet ba',
        'login_required': 'Ana buƙatar shiga',
        'login_message': 'Yi rajista don adana labarai da kuke so kuma samun damar amfani da su ba tare da intanet ba.',
        'login': 'Shiga',
        'register': 'Yi rajista',
        'email': 'Imel',
        'password': 'Kalmar sirri',
        'language': 'Harshe',
        'english': 'Turanci',
        'hausa': 'Hausa',
        'sign_out': 'Fita',
        'guest_user': 'Baƙo',
        'no_stories': 'Babu labarai',
        'no_favorites': 'Babu labarai da aka fi so har yanzu',
        'loading': 'Ana loda...',
        'error': 'Wani abu ya yi kuskure',
        'try_again': 'Sake gwadawa',
        'cancel': 'Soke',
        'ok': 'To',
        'all_categories': 'Duka',
        'dark_mode': 'Yanayin duhu',
        'about': 'Game da',
        'version': 'Sigar',
        'continue_as_guest': 'Ci gaba a matsayin baƙo',
        'sync_favorites': 'Daidaita abubuwan da ake so',
        'offline_mode': 'Yanayin rashin intanet',
        'network_error': 'Kuskuren hanyar sadarwa',
        'retry': 'Sake gwadawa',
        'welcome': 'Maraba da TALA',
        'welcome_message': 'Gano labarai masu ban mamaki cikin Hausa da Turanci',
      },
    };

    return translations[_currentLanguage]?[key] ?? key;
  }
}