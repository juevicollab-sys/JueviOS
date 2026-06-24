import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';
import 'supabase_provider.dart';

class ActivityNotifier extends AsyncNotifier<List<Activity>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Activity>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:activities')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'activities',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('activities')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    return data.map((e) => Activity.fromJson(e)).toList();
  }

  Future<void> log({
    required String type,
    required String title,
    String? description,
    ActivityEntityType? entityType,
    String? entityId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('activities').insert({
      'type': type,
      'title': title,
      'description': description,
      'entity_type': entityType?.value,
      'entity_id': entityId,
    });
  }
}

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, List<Activity>>(ActivityNotifier.new);
