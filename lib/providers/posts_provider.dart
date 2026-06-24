import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'supabase_provider.dart';

class PostsNotifier extends AsyncNotifier<List<Post>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Post>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('posts')
        .select()
        .order('scheduled_date', ascending: true);

    return data.map((e) => Post.fromJson(e)).toList();
  }

  Future<void> create({
    required String title,
    String? caption,
    required SocialNetwork network,
    required DateTime scheduledDate,
    PostStatus status = PostStatus.rascunho,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('posts').insert({
      'title': title,
      'caption': caption,
      'network': network.value,
      'scheduled_date': scheduledDate.toIso8601String().split('T').first,
      'status': status.value,
    });
  }

  Future<void> updateStatus(String id, PostStatus status) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('posts').update({'status': status.value}).eq('id', id);
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('posts').delete().eq('id', id);
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

// Posts agrupados por data para o calendário
final postsByDateProvider = Provider<Map<DateTime, List<Post>>>((ref) {
  final posts = ref.watch(postsProvider).valueOrNull ?? [];
  final map = <DateTime, List<Post>>{};
  for (final post in posts) {
    final day = DateTime(
        post.scheduledDate.year, post.scheduledDate.month, post.scheduledDate.day);
    map.putIfAbsent(day, () => []).add(post);
  }
  return map;
});
