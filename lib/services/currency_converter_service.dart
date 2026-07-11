import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterService {
  static String? _cachedKey;
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  static final Map<String, Map<String, double>> _cache = {};

  static const Map<String, double> _fallbackRates = {
    'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.5,
    'CAD': 1.36, 'CNY': 7.24, 'SEK': 10.45, 'INR': 83.1,
    'AED': 3.67, 'SAR': 3.75, 'TRY': 32.4, 'IQD': 1310.0,
  };

  static Future<String> _apiKey() async {
    if (_cachedKey != null) return _cachedKey!;
    try {
      _cachedKey = dotenv.env['EXCHANGE_API_KEY'] ?? '';
    } catch (_) {
      try {
        await dotenv.load();
        _cachedKey = dotenv.env['EXCHANGE_API_KEY'] ?? '';
      } catch (_) {
        _cachedKey = '';
      }
    }
    return _cachedKey!;
  }

  static Future<Map<String, double>> fetchRates(String base) async {
    if (_cache.containsKey(base)) return _cache[base]!;
    final key = await _apiKey();
    if (key.isEmpty) return Map.from(_fallbackRates);
    try {
      final res = await http.get(Uri.parse('$_baseUrl/$key/latest/$base'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rates = (data['conversion_rates'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble()));
          _cache[base] = rates;
          return rates;
        }
      }
    } catch (_) {}
    return Map.from(_fallbackRates);
  }

  static Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rates = await fetchRates(from);
    final rate = rates[to] ?? 1.0;
    return amount * rate;
  }

  static void clearCache() => _cache.clear();
}
