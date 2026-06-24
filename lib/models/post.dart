enum SocialNetwork {
  instagram('instagram'),
  tiktok('tiktok'),
  linkedin('linkedin'),
  youtube('youtube'),
  threads('threads');

  const SocialNetwork(this.value);
  final String value;

  static SocialNetwork fromString(String s) => SocialNetwork.values
      .firstWhere((e) => e.value == s, orElse: () => SocialNetwork.instagram);
}

enum PostStatus {
  rascunho('rascunho'),
  agendado('agendado'),
  publicado('publicado');

  const PostStatus(this.value);
  final String value;

  static PostStatus fromString(String s) => PostStatus.values
      .firstWhere((e) => e.value == s, orElse: () => PostStatus.rascunho);
}

class Post {
  final String id;
  final String title;
  final String? caption;
  final SocialNetwork network;
  final DateTime scheduledDate;
  final PostStatus status;
  final String? coverUrl;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.title,
    this.caption,
    required this.network,
    required this.scheduledDate,
    required this.status,
    this.coverUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        title: json['title'] as String,
        caption: json['caption'] as String?,
        network: SocialNetwork.fromString(json['network'] as String? ?? 'instagram'),
        scheduledDate: DateTime.parse(json['scheduled_date'] as String),
        status: PostStatus.fromString(json['status'] as String? ?? 'rascunho'),
        coverUrl: json['cover_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'caption': caption,
        'network': network.value,
        'scheduled_date': scheduledDate.toIso8601String().split('T').first,
        'status': status.value,
        'cover_url': coverUrl,
        'created_at': createdAt.toIso8601String(),
      };

  Post copyWith({
    String? id,
    String? title,
    String? caption,
    SocialNetwork? network,
    DateTime? scheduledDate,
    PostStatus? status,
    String? coverUrl,
    DateTime? createdAt,
  }) =>
      Post(
        id: id ?? this.id,
        title: title ?? this.title,
        caption: caption ?? this.caption,
        network: network ?? this.network,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        status: status ?? this.status,
        coverUrl: coverUrl ?? this.coverUrl,
        createdAt: createdAt ?? this.createdAt,
      );
}
