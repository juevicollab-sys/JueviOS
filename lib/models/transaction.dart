enum TransactionType {
  receita('receita'),
  despesa('despesa');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String s) => TransactionType.values
      .firstWhere((e) => e.value == s, orElse: () => TransactionType.receita);
}

class Transaction {
  final String id;
  final String title;
  final TransactionType type;
  final String? category;
  final double value;
  final DateTime date;
  final String? projectId;
  final String? projectTitle;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.title,
    required this.type,
    this.category,
    required this.value,
    required this.date,
    this.projectId,
    this.projectTitle,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        title: json['title'] as String,
        type: TransactionType.fromString(json['type'] as String? ?? 'receita'),
        category: json['category'] as String?,
        value: (json['value'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        projectId: json['project_id'] as String?,
        projectTitle: json['projects']?['title'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.value,
        'category': category,
        'value': value,
        'date': date.toIso8601String().split('T').first,
        'project_id': projectId,
        'created_at': createdAt.toIso8601String(),
      };

  Transaction copyWith({
    String? id,
    String? title,
    TransactionType? type,
    String? category,
    double? value,
    DateTime? date,
    String? projectId,
    String? projectTitle,
    DateTime? createdAt,
  }) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        category: category ?? this.category,
        value: value ?? this.value,
        date: date ?? this.date,
        projectId: projectId ?? this.projectId,
        projectTitle: projectTitle ?? this.projectTitle,
        createdAt: createdAt ?? this.createdAt,
      );
}
