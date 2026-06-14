import 'package:uuid/uuid.dart';

class Trip {
  final String id;
  final String title;
  final double price;
  final int nights;
  final String imagePath;
  final DateTime date;
  final String description;
  final bool isLiked;
  final DateTime createdAt;

  Trip({
    String? id,
    required this.title,
    required this.price,
    required this.nights,
    required this.imagePath,
    required this.date,
    this.description = '',
    this.isLiked = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Trip copyWith({
    String? id,
    String? title,
    double? price,
    int? nights,
    String? imagePath,
    DateTime? date,
    String? description,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      nights: nights ?? this.nights,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      description: description ?? this.description,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'nights': nights,
        'image_path': imagePath,
        'date': date.toIso8601String(),
        'description': description,
        'is_liked': isLiked ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        title: map['title'] as String,
        price: (map['price'] as num).toDouble(),
        nights: (map['nights'] as num).toInt(),
        imagePath: map['image_path'] as String,
        date: DateTime.parse(map['date'] as String),
        description: (map['description'] as String?) ?? '',
        isLiked: (map['is_liked'] as int?) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price.toString(),
        'nights': nights.toString(),
        'img': imagePath,
        'date': date.toIso8601String(),
        'description': description,
        'isLiked': isLiked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String?,
        title: json['title'] as String,
        price: double.tryParse(json['price'] as String) ?? 0,
        nights: int.tryParse(json['nights'] as String) ?? 1,
        imagePath: json['img'] as String,
        date: DateTime.parse(json['date'] as String),
        description: (json['description'] as String?) ?? '',
        isLiked: (json['isLiked'] as bool?) ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
