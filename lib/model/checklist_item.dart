import 'package:uuid/uuid.dart';

class ChecklistItem {
  final String id;
  final String tripId;
  final String title;
  final bool isChecked;

  ChecklistItem({
    String? id,
    required this.tripId,
    required this.title,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  ChecklistItem copyWith({
    String? id,
    String? tripId,
    String? title,
    bool? isChecked,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'title': title,
        'is_checked': isChecked ? 1 : 0,
      };

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      isChecked: (map['is_checked'] as int?) == 1,
    );
  }
}
