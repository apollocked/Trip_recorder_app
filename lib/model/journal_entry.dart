import 'dart:convert';
import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final String tripId;
  final DateTime date;
  final String title;
  final String text;
  final List<String> imagePaths;

  JournalEntry({
    String? id,
    required this.tripId,
    required this.date,
    required this.title,
    this.text = '',
    List<String>? imagePaths,
  })  : id = id ?? const Uuid().v4(),
        imagePaths = imagePaths ?? [];

  JournalEntry copyWith({
    String? id,
    String? tripId,
    DateTime? date,
    String? title,
    String? text,
    List<String>? imagePaths,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      title: title ?? this.title,
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'date': date.toIso8601String(),
        'title': title,
        'text': text,
        'image_paths': jsonEncode(imagePaths),
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    List<String> paths = [];
    final raw = map['image_paths'];
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) paths = decoded.cast<String>();
      } catch (_) {}
    }
    return JournalEntry(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      text: (map['text'] as String?) ?? '',
      imagePaths: paths,
    );
  }
}
