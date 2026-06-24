enum ContactStatus {
  cliente('cliente'),
  lead('lead'),
  prospect('prospect'),
  inativo('inativo');

  const ContactStatus(this.value);
  final String value;

  static ContactStatus fromString(String s) => ContactStatus.values
      .firstWhere((e) => e.value == s, orElse: () => ContactStatus.lead);
}

class Contact {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final ContactStatus status;
  final String? avatarUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contact({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.company,
    required this.status,
    this.avatarUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        company: json['company'] as String?,
        status: ContactStatus.fromString(json['status'] as String? ?? 'lead'),
        avatarUrl: json['avatar_url'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'status': status.value,
        'avatar_url': avatarUrl,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    ContactStatus? status,
    String? avatarUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        company: company ?? this.company,
        status: status ?? this.status,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
