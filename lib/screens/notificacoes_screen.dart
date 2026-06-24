import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/notification_item.dart';
import '../providers/notifications_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class NotificacoesScreen extends ConsumerWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro ao carregar notificações', style: JueviText.label())),
      data: (notifs) {
        if (notifs.isEmpty) {
          return Center(child: Text('Nenhuma notificação', style: JueviText.label()));
        }
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotifTile(
                notif: notifs[i],
                onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notifs[i].id),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 80,
              child: IgnorePointer(
                child: const DecoratedBox(
                  decoration: BoxDecoration(
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

class _NotifTile extends StatelessWidget {
  final NotificationItem notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  Color get _color => switch (notif.type) {
        NotificationType.projeto    => JueviColors.lavanda,
        NotificationType.financeiro => JueviColors.verde,
        NotificationType.crm        => JueviColors.ciano,
        NotificationType.geral      => JueviColors.chumbo,
      };

  IconData get _icon => switch (notif.type) {
        NotificationType.projeto    => Icons.folder_outlined,
        NotificationType.financeiro => Icons.attach_money,
        NotificationType.crm        => Icons.person_outline,
        NotificationType.geral      => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final timeStr = timeago.format(notif.createdAt, locale: 'pt_BR');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: JueviColors.bgCard,
          borderRadius: BorderRadius.circular(40),
          boxShadow: notif.isRead
              ? null
              : [
                  BoxShadow(
                    color: _color.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: notif.isRead
              ? null
              : Border.all(color: _color.withOpacity(0.22), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _color.withOpacity(notif.isRead ? 0.1 : 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _color.withOpacity(notif.isRead ? 0.5 : 1),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    notif.title,
                    style: JueviText.bodyBold(size: 14).copyWith(
                      color: notif.isRead
                          ? JueviColors.chumbo.withOpacity(0.5)
                          : JueviColors.chumbo,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.message ?? '',
                    style: JueviText.label(
                      color: notif.isRead ? JueviColors.chumbo.withOpacity(0.35) : null,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: JueviText.label(size: 11)),
                if (!notif.isRead) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
