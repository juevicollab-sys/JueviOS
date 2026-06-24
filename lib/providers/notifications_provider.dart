import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_item.dart';
import 'supabase_provider.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationItem>> {
  RealtimeChannel? _channel;

  @override
  Future<List<NotificationItem>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);

    return data.map((e) => NotificationItem.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('notifications').update({'is_read': true}).eq('is_read', false);
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('notifications').delete().eq('id', id);
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
        NotificationsNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
