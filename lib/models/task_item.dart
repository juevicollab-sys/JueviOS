class TaskItem {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? dueDate;
  final String? projectId;
  final String? projectTitle;
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    required this.title,
    required this.isDone,
    this.dueDate,
    this.projectId,
    this.projectTitle,
    required this.createdAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: json['is_done'] as bool? ?? false,
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        projectId: json['project_id'] as String?,
        projectTitle: json['projects']?['title'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'is_done': isDone,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'project_id': projectId,
        'created_at': createdAt.toIso8601String(),
      };

  TaskItem copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? dueDate,
    String? projectId,
    String? projectTitle,
    DateTime? createdAt,
  }) =>
      TaskItem(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        dueDate: dueDate ?? this.dueDate,
        projectId: projectId ?? this.projectId,
        projectTitle: projectTitle ?? this.projectTitle,
        createdAt: createdAt ?? this.createdAt,
      );
}
