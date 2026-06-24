import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AtividadeScreen extends ConsumerWidget {
  const AtividadeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro ao carregar atividades', style: JueviText.label())),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(child: Text('Nenhuma atividade ainda', style: JueviText.label()));
        }
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ActivityTile(activity: activities[i]),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 80,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00E3D8C5), Color(0xFFE3D8C5)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  const _ActivityTile({required this.activity});

  Color get _color => switch (activity.entityType) {
        ActivityEntityType.projeto    => JueviColors.lavanda,
        ActivityEntityType.contato    => JueviColors.ciano,
        ActivityEntityType.financeiro => JueviColors.mostarda,
        ActivityEntityType.post       => JueviColors.tangerina,
        null                          => JueviColors.verde,
      };

  IconData get _icon => switch (activity.entityType) {
        ActivityEntityType.projeto    => Icons.folder_outlined,
        ActivityEntityType.contato    => Icons.person_outline,
        ActivityEntityType.financeiro => Icons.attach_money,
        ActivityEntityType.post       => Icons.calendar_today_outlined,
        null                          => Icons.check_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final timeStr = timeago.format(activity.createdAt, locale: 'pt_BR');

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: JueviColors.chumbo.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(activity.title, style: JueviText.bodyBold(size: 14)),
                const SizedBox(height: 3),
                Text(activity.description ?? '', style: JueviText.label()),
              ],
            ),
          ),
          Text(timeStr, style: JueviText.label(size: 11)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
