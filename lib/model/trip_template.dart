import 'dart:convert';
import 'package:uuid/uuid.dart';

class TripTemplate {
  final String id;
  final String name;
  final String category;
  final int nights;
  final String description;
  final List<String> packingItems;
  final String currency;

  TripTemplate({
    String? id,
    required this.name,
    this.category = 'other',
    this.nights = 1,
    this.description = '',
    this.packingItems = const [],
    this.currency = 'USD',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'nights': nights,
    'description': description,
    'packing_items': jsonEncode(packingItems),
    'currency': currency,
  };

  factory TripTemplate.fromMap(Map<String, dynamic> map) {
    List<String> items = [];
    final raw = map['packing_items'];
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) items = decoded.cast<String>();
      } catch (_) {}
    }
    return TripTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      category: (map['category'] as String?) ?? 'other',
      nights: (map['nights'] as num?)?.toInt() ?? 1,
      description: (map['description'] as String?) ?? '',
      packingItems: items,
      currency: (map['currency'] as String?) ?? 'USD',
    );
  }

  TripTemplate copyWith({
    String? name,
    String? category,
    int? nights,
    String? description,
    List<String>? packingItems,
    String? currency,
  }) {
    return TripTemplate(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      nights: nights ?? this.nights,
      description: description ?? this.description,
      packingItems: packingItems ?? this.packingItems,
      currency: currency ?? this.currency,
    );
  }
}
