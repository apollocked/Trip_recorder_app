import 'package:uuid/uuid.dart';

class CustomCategory {
  final String id;
  final String name;
  final String type;
  final String icon;

  CustomCategory({
    String? id,
    required this.name,
    required this.type,
    this.icon = 'label',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'icon': icon,
  };

  factory CustomCategory.fromMap(Map<String, dynamic> map) => CustomCategory(
    id: map['id'] as String,
    name: map['name'] as String,
    type: map['type'] as String,
    icon: (map['icon'] as String?) ?? 'label',
  );

  CustomCategory copyWith({String? name, String? type, String? icon}) {
    return CustomCategory(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}
