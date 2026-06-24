import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen>
    with SingleTickerProviderStateMixin {
  int _selected = 0;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _switchProfile(int i) {
    if (i == _selected) return;
    _anim.reverse().then((_) {
      setState(() => _selected = i);
      _anim.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final tasks    = ref.watch(tasksProvider).valueOrNull ?? [];

    final entregues  = projects.where((p) => p.status == ProjectStatus.entregue).length;
    final doneTasks  = tasks.where((t) => t.isDone).length;
    final maxProj  = projects.isEmpty ? 30.0 : (projects.length < 30 ? 30.0 : projects.length.toDouble());
    final maxTasks = tasks.isEmpty    ? 100.0 : (tasks.length < 100  ? 100.0 : tasks.length.toDouble());

    final studioStats = [
      _Stat(label: 'Projetos concluídos',    value: entregues.toDouble(),  max: maxProj),
      _Stat(label: 'Tarefas feitas',         value: doneTasks.toDouble(),  max: maxTasks),
      _Stat(label: 'Score de entrega',       value: 9.2,                   max: 10.0),
    ];

    final profiles = _buildProfiles(studioStats);
    final profile  = profiles[_selected];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: JueviColors.bgCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(profiles.length, (i) {
                final active = i == _selected;
                return GestureDetector(
                  onTap: () => _switchProfile(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? profiles[i].color : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profiles[i].nickname,
                      style: JueviText.bodyBold(
                        size: 16,
                        color: active ? Colors.white : JueviColors.chumbo.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: JueviColors.bgCard,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: profile.color.withOpacity(0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(profile.charAsset, height: 160),
                    const SizedBox(height: 16),
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: profile.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: profile.color, width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          profile.nickname,
                          style: JueviText.pageTitle(size: 30).copyWith(color: profile.color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(profile.name,     style: JueviText.bodyBold(size: 20)),
                    const SizedBox(height: 4),
                    Text(profile.role,     style: JueviText.label()),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: profile.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(profile.archetype, style: JueviText.label(color: profile.color, size: 12)),
                    ),
                    const SizedBox(height: 28),
                    ...profile.stats.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(s.label, style: JueviText.body(size: 13)),
                                  Text('${s.value.toInt()}/${s.max.toInt()}', style: JueviText.label(size: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: (s.value / s.max).clamp(0.0, 1.0),
                                  backgroundColor: profile.color.withOpacity(0.12),
                                  valueColor: AlwaysStoppedAnimation(profile.color),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_Profile> _buildProfiles(List<_Stat> stats) => [
  _Profile(
    name: 'Lucas Viegas',
    nickname: 'Vi',
    role: 'Direção Técnica & Audiovisual',
    archetype: 'O Visionário · O Rebelde',
    charAsset: 'assets/characters/char-vontade-full.png',
    color: JueviColors.carmesim,
    stats: stats,
  ),
  _Profile(
    name: 'Julia Macuco',
    nickname: 'Ju',
    role: 'Direção Criativa & Branding',
    archetype: 'A Criadora · A Cuidadora',
    charAsset: 'assets/characters/char-calma-full.png',
    color: JueviColors.lavanda,
    stats: stats,
  ),
];

class _Stat {
  final String label;
  final double value;
  final double max;
  const _Stat({required this.label, required this.value, required this.max});
}

class _Profile {
  final String       name;
  final String       nickname;
  final String       role;
  final String       archetype;
  final String       charAsset;
  final Color        color;
  final List<_Stat>  stats;

  const _Profile({
    required this.name,
    required this.nickname,
    required this.role,
    required this.archetype,
    required this.charAsset,
    required this.color,
    required this.stats,
  });
}
