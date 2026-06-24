import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  ProjectStatus? _filter;

  Color _colorFor(ProjectStatus s) => switch (s) {
        ProjectStatus.briefing  => JueviColors.lavanda,
        ProjectStatus.producao  => JueviColors.ciano,
        ProjectStatus.revisao   => JueviColors.tangerina,
        ProjectStatus.entregue  => JueviColors.verde,
        ProjectStatus.arquivado => JueviColors.chumbo,
      };

  String _labelFor(ProjectStatus s) => switch (s) {
        ProjectStatus.briefing  => 'Briefing',
        ProjectStatus.producao  => 'Em andamento',
        ProjectStatus.revisao   => 'Em revisão',
        ProjectStatus.entregue  => 'Concluído',
        ProjectStatus.arquivado => 'Arquivado',
      };

  static const _filterStatuses = [
    ProjectStatus.briefing,
    ProjectStatus.producao,
    ProjectStatus.revisao,
    ProjectStatus.entregue,
  ];

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final visible  = _filter == null
        ? projects
        : projects.where((p) => p.status == _filter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Text('FILTRAR', style: JueviText.label(size: 11)),
              const SizedBox(width: 12),
              ..._filterStatuses.map((s) {
                final c      = _colorFor(s);
                final active = _filter == s;
                return GestureDetector(
                  onTap: () => setState(() => _filter = active ? null : s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width:  active ? 32 : 26,
                    height: active ? 32 : 26,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: active ? Border.all(color: JueviColors.chumbo, width: 2.5) : null,
                      boxShadow: active
                          ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                  ),
                );
              }),
              if (_filter != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _filter = null),
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: JueviColors.bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: JueviColors.chumbo.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.close, size: 14, color: JueviColors.chumbo),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: visible.isEmpty
              ? Center(child: Text('Nenhum projeto', style: JueviText.label()))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 28,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (_, i) {
                    final p = visible[i];
                    return _Polaroid(
                      title:    p.title,
                      category: _labelFor(p.status),
                      color:    _colorFor(p.status),
                      pinColor: _colorFor(p.status),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Polaroid extends StatefulWidget {
  final String title;
  final String category;
  final Color  color;
  final Color  pinColor;

  const _Polaroid({
    required this.title,
    required this.category,
    required this.color,
    required this.pinColor,
  });

  @override
  State<_Polaroid> createState() => _PolaroidState();
}

class _PolaroidState extends State<_Polaroid> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(top: -14, child: _Thumbtack(color: widget.pinColor)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.rotationZ(_hovered ? 0 : 0.025),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: JueviColors.chumbo.withOpacity(_hovered ? 0.28 : 0.14),
                  blurRadius: _hovered ? 22 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Icon(Icons.image_outlined, color: widget.color, size: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Column(
                    children: [
                      Text(widget.title,    style: JueviText.bodyBold(size: 13), textAlign: TextAlign.center),
                      Text(widget.category, style: JueviText.label()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbtack extends StatelessWidget {
  final Color color;
  const _Thumbtack({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(1, 2))],
          ),
          child: Center(
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle)),
          ),
        ),
        Container(width: 2, height: 10, color: color.withOpacity(0.55)),
      ],
    );
  }
}
