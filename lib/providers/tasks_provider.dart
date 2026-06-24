import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_item.dart';
import 'supabase_provider.dart';

class TasksNotifier extends AsyncNotifier<List<TaskItem>> {
  RealtimeChannel? _channel;

  @override
  Future<List<TaskItem>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:tasks')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('tasks')
        .select('*, projects(title)')
        .order('created_at', ascending: true);

    return data.map((e) => TaskItem.fromJson(e)).toList();
  }

  Future<void> create({
    required String title,
    DateTime? dueDate,
    String? projectId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('tasks').insert({
      'title': title,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'project_id': projectId,
    });
  }

  Future<void> toggle(String id, bool currentValue) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('tasks').update({'is_done': !currentValue}).eq('id', id);
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('tasks').delete().eq('id', id);
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskItem>>(TasksNotifier.new);

final pendingTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks.where((t) => !t.isDone).toList();
});
