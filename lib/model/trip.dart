import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'trip_category.dart';

class Trip {
  final String id;
  final String title;
  final double price;
  final int nights;
  final List<String> imagePaths;
  final DateTime date;
  final String description;
  final bool isLiked;
  final DateTime createdAt;
  final TripCategory category;
  final double rating;

  Trip({
    String? id,
    required this.title,
    required this.price,
    required this.nights,
    List<String>? imagePaths,
    required this.date,
    this.description = '',
    this.isLiked = false,
    DateTime? createdAt,
    this.category = TripCategory.other,
    this.rating = 0.0,
  })  : id = id ?? const Uuid().v4(),
        imagePaths = imagePaths ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get primaryImagePath =>
      imagePaths.isNotEmpty ? imagePaths.first : '';

  Trip copyWith({
    String? id,
    String? title,
    double? price,
    int? nights,
    List<String>? imagePaths,
    DateTime? date,
    String? description,
    bool? isLiked,
    DateTime? createdAt,
    TripCategory? category,
    double? rating,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      nights: nights ?? this.nights,
      imagePaths: imagePaths ?? this.imagePaths,
      date: date ?? this.date,
      description: description ?? this.description,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'nights': nights,
        'image_paths': jsonEncode(imagePaths),
        'date': date.toIso8601String(),
        'description': description,
        'is_liked': isLiked ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'category': category.name,
        'rating': rating,
      };

  factory Trip.fromMap(Map<String, dynamic> map) {
    List<String> paths = [];
    final raw = map['image_paths'];
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          paths = decoded.cast<String>();
        }
      } catch (_) {
        if (raw.isNotEmpty) paths = [raw];
      }
    }
    if (paths.isEmpty && map.containsKey('image_path')) {
      final old = map['image_path'] as String?;
      if (old != null && old.isNotEmpty) paths = [old];
    }
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      nights: (map['nights'] as num).toInt(),
      imagePaths: paths,
      date: DateTime.parse(map['date'] as String),
      description: (map['description'] as String?) ?? '',
      isLiked: (map['is_liked'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      category: TripCategory.fromString((map['category'] as String?) ?? 'other'),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price.toString(),
        'nights': nights.toString(),
        'image_paths': imagePaths,
        'date': date.toIso8601String(),
        'description': description,
        'isLiked': isLiked,
        'createdAt': createdAt.toIso8601String(),
        'category': category.name,
        'rating': rating,
      };

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<String> paths = [];
    final raw = json['image_paths'];
    if (raw is List) {
      paths = raw.cast<String>();
    } else if (json['img'] is String) {
      paths = [json['img'] as String];
    }
    return Trip(
      id: json['id'] as String?,
      title: json['title'] as String,
      price: double.tryParse(json['price'] as String) ?? 0,
      nights: int.tryParse(json['nights'] as String) ?? 1,
      imagePaths: paths,
      date: DateTime.parse(json['date'] as String),
      description: (json['description'] as String?) ?? '',
      isLiked: (json['isLiked'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      category: TripCategory.fromString((json['category'] as String?) ?? 'other'),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
