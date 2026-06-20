import 'package:uuid/uuid.dart';

class ChecklistItem {
  final String id;
  final String tripId;
  final String title;
  final bool isChecked;
  final String category;

  ChecklistItem({
    String? id,
    required this.tripId,
    required this.title,
    this.isChecked = false,
    this.category = 'general',
  }) : id = id ?? const Uuid().v4();

  ChecklistItem copyWith({
    String? id,
    String? tripId,
    String? title,
    bool? isChecked,
    String? category,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'title': title,
        'is_checked': isChecked ? 1 : 0,
        'category': category,
      };

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      isChecked: (map['is_checked'] as int?) == 1,
      category: (map['category'] as String?) ?? 'general',
    );
  }
}
