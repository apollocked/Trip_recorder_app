import 'package:flutter/material.dart';
import 'app_localizations.dart';

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
        return 'English';
      default:
        return 'English';
    }
  }
}

extension AppLocalizationsMonthX on AppLocalizations {
  String monthFull(int month) {
    final months = monthsFull.split(',');
    return months[month - 1];
  }

  String monthShort(int month) {
    final months = monthsShort.split(',');
    return months[month - 1];
  }

  String formatMonthYear(DateTime date) {
    return '${monthFull(date.month)} ${date.year}';
  }

  String formatDateAbbreviated(DateTime date) {
    return '${monthShort(date.month)} ${date.day}, ${date.year}';
  }
}
