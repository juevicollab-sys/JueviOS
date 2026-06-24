enum ProjectStatus {
  briefing('briefing'),
  producao('producao'),
  revisao('revisao'),
  entregue('entregue'),
  arquivado('arquivado');

  const ProjectStatus(this.value);
  final String value;

  static ProjectStatus fromString(String s) => ProjectStatus.values
      .firstWhere((e) => e.value == s, orElse: () => ProjectStatus.briefing);
}

class Project {
  final String id;
  final String title;
  final String? clientId;
  final String? clientName;
  final ProjectStatus status;
  final int phase;
  final double? value;
  final DateTime? deadline;
  final String? description;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    this.clientId,
    this.clientName,
    required this.status,
    required this.phase,
    this.value,
    this.deadline,
    this.description,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        title: json['title'] as String,
        clientId: json['client_id'] as String?,
        clientName: json['contacts']?['name'] as String?,
        status: ProjectStatus.fromString(json['status'] as String? ?? 'briefing'),
        phase: (json['phase'] as int?) ?? 0,
        value: (json['value'] as num?)?.toDouble(),
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        description: json['description'] as String?,
        coverUrl: json['cover_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'client_id': clientId,
        'status': status.value,
        'phase': phase,
        'value': value,
        'deadline': deadline?.toIso8601String().split('T').first,
        'description': description,
        'cover_url': coverUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Project copyWith({
    String? id,
    String? title,
    String? clientId,
    String? clientName,
    ProjectStatus? status,
    int? phase,
    double? value,
    DateTime? deadline,
    String? description,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Project(
        id: id ?? this.id,
        title: title ?? this.title,
        clientId: clientId ?? this.clientId,
        clientName: clientName ?? this.clientName,
        status: status ?? this.status,
        phase: phase ?? this.phase,
        value: value ?? this.value,
        deadline: deadline ?? this.deadline,
        description: description ?? this.description,
        coverUrl: coverUrl ?? this.coverUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
