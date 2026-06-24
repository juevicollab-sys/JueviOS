import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import 'supabase_provider.dart';

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Project>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:projects')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'projects',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('projects')
        .select('*, contacts(name)')
        .order('created_at', ascending: false);

    return data.map((e) => Project.fromJson(e)).toList();
  }

  Future<void> create({
    required String title,
    String? clientId,
    ProjectStatus status = ProjectStatus.briefing,
    int phase = 0,
    double? value,
    DateTime? deadline,
    String? description,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('projects').insert({
      'title': title,
      'client_id': clientId,
      'status': status.value,
      'phase': phase,
      'value': value,
      'deadline': deadline?.toIso8601String().split('T').first,
      'description': description,
    });
  }

  Future<void> updateProject(Project project) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('projects').update(project.toJson()).eq('id', project.id);
  }

  Future<void> advancePhase(String id, int currentPhase) async {
    if (currentPhase >= 4) return;
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client
        .from('projects')
        .update({'phase': currentPhase + 1}).eq('id', id);
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('projects').delete().eq('id', id);
  }
}

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);
