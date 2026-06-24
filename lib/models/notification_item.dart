enum NotificationType {
  projeto('projeto'),
  financeiro('financeiro'),
  crm('crm'),
  geral('geral');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String s) => NotificationType.values
      .firstWhere((e) => e.value == s, orElse: () => NotificationType.geral);
}

class NotificationItem {
  final String id;
  final String title;
  final String? message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String?,
        type: NotificationType.fromString(json['type'] as String? ?? 'geral'),
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.value,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) =>
      NotificationItem(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
}
