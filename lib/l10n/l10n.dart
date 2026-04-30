import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
    const Locale('ku'),
  ];

  static String getNativeName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      case 'en':
      default:
        return 'English';
    }
  }
}
