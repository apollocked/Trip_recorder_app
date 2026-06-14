class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo(this.code, this.symbol, this.name);

  static const List<CurrencyInfo> all = [
    CurrencyInfo('USD', '\$', 'US Dollar'),
    CurrencyInfo('EUR', '€', 'Euro'),
    CurrencyInfo('GBP', '£', 'British Pound'),
    CurrencyInfo('JPY', '¥', 'Japanese Yen'),
    CurrencyInfo('CAD', 'C\$', 'Canadian Dollar'),
    CurrencyInfo('AUD', 'A\$', 'Australian Dollar'),
    CurrencyInfo('CHF', 'Fr', 'Swiss Franc'),
    CurrencyInfo('CNY', '¥', 'Chinese Yuan'),
    CurrencyInfo('SEK', 'kr', 'Swedish Krona'),
    CurrencyInfo('NOK', 'kr', 'Norwegian Krone'),
    CurrencyInfo('DKK', 'kr', 'Danish Krone'),
    CurrencyInfo('INR', '₹', 'Indian Rupee'),
    CurrencyInfo('BRL', 'R\$', 'Brazilian Real'),
    CurrencyInfo('MXN', 'Mex\$', 'Mexican Peso'),
    CurrencyInfo('AED', 'د.إ', 'UAE Dirham'),
    CurrencyInfo('SAR', '﷼', 'Saudi Riyal'),
    CurrencyInfo('IQD', 'د.ع', 'Iraqi Dinar'),
    CurrencyInfo('TRY', '₺', 'Turkish Lira'),
  ];

  static CurrencyInfo fromCode(String code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => const CurrencyInfo('USD', '\$', 'US Dollar'),
    );
  }

  static String symbolFor(String code) => fromCode(code).symbol;
}
