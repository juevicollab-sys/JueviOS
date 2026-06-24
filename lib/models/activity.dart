enum ActivityEntityType {
  projeto('projeto'),
  contato('contato'),
  financeiro('financeiro'),
  post('post');

  const ActivityEntityType(this.value);
  final String value;

  static ActivityEntityType fromString(String s) => ActivityEntityType.values
      .firstWhere((e) => e.value == s, orElse: () => ActivityEntityType.projeto);
}

class Activity {
  final String id;
  final String type;
  final String title;
  final String? description;
  final ActivityEntityType? entityType;
  final String? entityId;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.entityType,
    this.entityId,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        entityType: json['entity_type'] != null
            ? ActivityEntityType.fromString(json['entity_type'] as String)
            : null,
        entityId: json['entity_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'entity_type': entityType?.value,
        'entity_id': entityId,
        'created_at': createdAt.toIso8601String(),
      };

  Activity copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    ActivityEntityType? entityType,
    String? entityId,
    DateTime? createdAt,
  }) =>
      Activity(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        description: description ?? this.description,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        createdAt: createdAt ?? this.createdAt,
      );
}
