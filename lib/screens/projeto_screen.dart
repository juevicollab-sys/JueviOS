import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../models/project.dart';
import '../models/task_item.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

final _brl = NumberFormat.simpleCurrency(locale: 'pt_BR');

class ProjetoScreen extends ConsumerWidget {
  const ProjetoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final allTasks = ref.watch(tasksProvider).valueOrNull ?? [];

    final active = projects.where((p) =>
        p.status != ProjectStatus.entregue &&
        p.status != ProjectStatus.arquivado).toList();

    if (projects.isEmpty) {
      return Center(child: Text('Nenhum projeto ainda', style: JueviText.label()));
    }

    final project  = active.isNotEmpty ? active.first : projects.first;
    final tasks    = allTasks.where((t) => t.projectId == project.id).toList();
    final progress = (project.phase / 4.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _ProjectCard(project: project, progress: progress)),
                const SizedBox(width: 14),
                Expanded(child: _PhasesCard(currentPhase: project.phase)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            flex: 60,
            child: _CorkBoard(
              tasks: tasks,
              onToggle: (task) => ref
                  .read(tasksProvider.notifier)
                  .toggle(task.id, task.isDone),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Project info card
// ──────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final Project project;
  final double progress;
  const _ProjectCard({required this.project, required this.progress});

  Color _statusColor(ProjectStatus s) => switch (s) {
        ProjectStatus.briefing  => JueviColors.lavanda,
        ProjectStatus.producao  => JueviColors.ciano,
        ProjectStatus.revisao   => JueviColors.tangerina,
        ProjectStatus.entregue  => JueviColors.verde,
        ProjectStatus.arquivado => JueviColors.chumbo,
      };

  String _statusLabel(ProjectStatus s) => switch (s) {
        ProjectStatus.briefing  => 'Briefing',
        ProjectStatus.producao  => 'Em andamento',
        ProjectStatus.revisao   => 'Em revisão',
        ProjectStatus.entregue  => 'Concluído',
        ProjectStatus.arquivado => 'Arquivado',
      };

  @override
  Widget build(BuildContext context) {
    final color      = _statusColor(project.status);
    final label      = _statusLabel(project.status);
    final pct        = (progress * 100).round();
    final deadlineStr = project.deadline != null
        ? DateFormat('dd/MM/yyyy').format(project.deadline!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: JueviColors.chumbo.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: JueviText.pageTitle(size: 22)),
                    const SizedBox(height: 3),
                    Text(project.clientName ?? project.clientId ?? '', style: JueviText.label()),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(label, style: JueviText.label(color: color, size: 11)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progresso geral', style: JueviText.label(size: 12)),
              Text('$pct%', style: JueviText.bodyBold(size: 12, color: JueviColors.verde)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: JueviColors.verde.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(JueviColors.verde),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prazo', style: JueviText.label(size: 11)),
                  Text(
                    deadlineStr,
                    style: JueviText.bodyBold(size: 13, color: JueviColors.carmesim),
                  ),
                ],
              ),
              if (project.value != null)
                Text(
                  _brl.format(project.value),
                  style: JueviText.pageTitle(size: 20).copyWith(color: JueviColors.verde),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Phase timeline
// ──────────────────────────────────────────────
class _PhasesCard extends StatelessWidget {
  final int currentPhase;
  const _PhasesCard({required this.currentPhase});

  static const _phaseLabels = [
    'Briefing & Imersão',
    'Direção Criativa',
    'Desenvolvimento Visual',
    'Revisão com cliente',
    'Entrega final',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FASES', style: JueviText.accent(size: 13)),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: List.generate(_phaseLabels.length, (i) {
                final done   = i < currentPhase;
                final active = i == currentPhase;
                final isLast = i == _phaseLabels.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: done
                                ? JueviColors.verde
                                : active
                                    ? JueviColors.tangerina.withOpacity(0.15)
                                    : JueviColors.bgMain,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: done
                                  ? JueviColors.verde
                                  : active
                                      ? JueviColors.tangerina
                                      : JueviColors.chumbo.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: done
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : active
                                  ? Center(
                                      child: Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(
                                          color: JueviColors.tangerina,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        if (!isLast)
                          Container(
                            width: 2, height: 22,
                            color: done
                                ? JueviColors.verde.withOpacity(0.35)
                                : JueviColors.chumbo.withOpacity(0.1),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: Text(
                          _phaseLabels[i],
                          style: JueviText.body(
                            size: 12,
                            color: done || active
                                ? JueviColors.chumbo
                                : JueviColors.chumbo.withOpacity(0.4),
                          ).copyWith(
                            fontWeight: done || active ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Cork board
// ──────────────────────────────────────────────
class _CorkBoard extends StatelessWidget {
  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onToggle;

  const _CorkBoard({required this.tasks, required this.onToggle});

  static const _stickies = [
    _Sticky(color: Color(0xFF9ED5DD), text: 'Revisar paleta\ncom cliente',    angle: -3.0, left: 200, top: 24),
    _Sticky(color: Color(0xFFEB783C), text: 'Exportar arquivos\n300dpi',      angle:  2.5, left: 360, top: 50),
    _Sticky(color: Color(0xFFEAC11B), text: 'Gravar vídeo\ninstitucional',    angle: -1.5, left: 510, top: 20),
    _Sticky(color: Color(0xFF9ED5DD), text: 'Mockup\nembalagem',              angle:  3.0, left: 300, top: 155),
  ];

  static const _polaroids = [
    _PolaroidItem(label: 'Moodboard',   color: JueviColors.lavanda,   right: 20,  top: 20),
    _PolaroidItem(label: 'Referências', color: JueviColors.tangerina, right: 140, top: 55),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFB8834A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: JueviColors.chumbo.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(50, (i) {
              final r = math.Random(i * 17 + 3);
              return Positioned(
                left: r.nextDouble() * 1400,
                top: r.nextDouble() * 400,
                child: Container(
                  width: r.nextDouble() * 6 + 2,
                  height: r.nextDouble() * 6 + 2,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
            for (final s in _stickies)
              Positioned(left: s.left, top: s.top, child: _StickyNote(sticky: s)),
            for (final p in _polaroids)
              Positioned(right: p.right, top: p.top, child: _Polaroid(item: p)),
            Positioned(
              bottom: 0, left: 10,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomLeft,
                children: [
                  Positioned(
                    bottom: 60, left: 0,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/characters/char-cloud.png',
                        width: 70,
                        opacity: const AlwaysStoppedAnimation(0.6),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Image.asset('assets/characters/char-motivacao-full.png', height: 160),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 14, left: 130,
              child: _CorkChecklist(items: tasks.take(4).toList(), onToggle: onToggle),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sticky {
  final Color color;
  final String text;
  final double angle;
  final double left;
  final double top;
  const _Sticky({required this.color, required this.text, required this.angle, required this.left, required this.top});
}

class _PolaroidItem {
  final String label;
  final Color color;
  final double right;
  final double top;
  const _PolaroidItem({required this.label, required this.color, required this.right, required this.top});
}

class _StickyNote extends StatelessWidget {
  final _Sticky sticky;
  const _StickyNote({required this.sticky});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: sticky.angle * math.pi / 180,
      child: Container(
        width: 140, height: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sticky.color,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 8, offset: const Offset(2, 4)),
          ],
        ),
        child: Text(
          sticky.text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A), height: 1.4),
        ),
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  final _PolaroidItem item;
  const _Polaroid({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: JueviColors.carmesim,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(1, 2))],
                ),
                child: Center(
                  child: Container(width: 5, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle)),
                ),
              ),
              Container(width: 2, height: 8, color: JueviColors.carmesim.withOpacity(0.6)),
            ],
          ),
        ),
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(2, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 72,
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                decoration: BoxDecoration(color: item.color.withOpacity(0.2)),
                child: Center(child: Icon(Icons.image_outlined, color: item.color, size: 30)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: Text(item.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CorkChecklist extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onToggle;

  const _CorkChecklist({required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: JueviColors.mostarda,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(2, -2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('CHECKLIST', style: JueviText.accent(size: 10).copyWith(color: Colors.white.withOpacity(0.9), letterSpacing: 1.2)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Sem tarefas', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)))
          else
            ...items.map((task) => GestureDetector(
                  onTap: () => onToggle(task),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 13, height: 13,
                          decoration: BoxDecoration(
                            color: task.isDone ? Colors.white.withOpacity(0.9) : Colors.transparent,
                            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: task.isDone ? const Icon(Icons.check, size: 9, color: JueviColors.mostarda) : null,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(task.isDone ? 0.45 : 0.92),
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
