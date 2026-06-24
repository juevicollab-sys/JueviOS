import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/notifications_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../core/nav_constants.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String currentRoute;
  final LayoutType layoutType;
  final double height;

  const AppHeader({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.layoutType,
    this.height = 80,
  });

  bool get _isDesktop => layoutType == LayoutType.desktop;

  String? _prevRoute() {
    final idx = navRoutes.indexOf(currentRoute);
    if (idx < 0) return null;
    return navRoutes[(idx - 1 + navRoutes.length) % navRoutes.length];
  }

  String? _nextRoute() {
    final idx = navRoutes.indexOf(currentRoute);
    if (idx < 0) return null;
    return navRoutes[(idx + 1) % navRoutes.length];
  }

  @override
  Widget build(BuildContext context) {
    final logoH   = height * 0.60;
    final titleSz = height * 0.50;
    final prev    = _prevRoute();
    final next    = _nextRoute();

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 20 : 14),
      color: JueviColors.bgMain,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Logo JU&VI grande ──
          SvgPicture.asset(
            'assets/logos/logo-abreviada-red.svg',
            height: logoH,
          ),
          const SizedBox(width: 14),

          // ── Título + setas ──
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: JueviText.pageTitle(size: titleSz),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _PageNavArrows(prevRoute: prev, nextRoute: next),
              ],
            ),
          ),

          const Spacer(),

          // ── Ações (desktop) ──
          if (_isDesktop) ...[
            _HeaderIcon(
              icon: Icons.calendar_month_outlined,
              tooltip: 'Redes Sociais',
              onTap: () => context.go('/redes-sociais'),
            ),
            _NotifIcon(onTap: () => context.go('/notificacoes')),
            const SizedBox(width: 4),
            _ProfileMenu(),
            const SizedBox(width: 8),
            _WindowControl(
              icon: Icons.remove,
              onTap: () => windowManager.minimize(),
            ),
            _WindowControl(
              icon: Icons.crop_square,
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _WindowControl(
              icon: Icons.close,
              onTap: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Setas ↑↓ de navegação entre páginas
// ──────────────────────────────────────────────
class _PageNavArrows extends StatelessWidget {
  final String? prevRoute;
  final String? nextRoute;

  const _PageNavArrows({this.prevRoute, this.nextRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowBtn(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: prevRoute != null ? () => context.go(prevRoute!) : null,
        ),
        const SizedBox(height: 1),
        _ArrowBtn(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: nextRoute != null ? () => context.go(nextRoute!) : null,
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ArrowBtn({required this.icon, this.onTap});

  @override
  State<_ArrowBtn> createState() => _ArrowBtnState();
}

class _ArrowBtnState extends State<_ArrowBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: active ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: active ? (_hovered ? 0.85 : 0.35) : 0.12,
          child: Icon(widget.icon, size: 17, color: JueviColors.chumbo),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Ícone de ação no header
// ──────────────────────────────────────────────
class _HeaderIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34, height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hovered
                  ? JueviColors.chumbo.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, size: 19,
                color: JueviColors.chumbo.withOpacity(0.65)),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Ícone de notificações
// ──────────────────────────────────────────────
class _NotifIcon extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const _NotifIcon({required this.onTap});

  @override
  ConsumerState<_NotifIcon> createState() => _NotifIconState();
}

class _NotifIconState extends ConsumerState<_NotifIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider);

    return Tooltip(
      message: 'Notificações',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34, height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hovered
                  ? JueviColors.chumbo.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_outlined, size: 19,
                    color: JueviColors.chumbo.withOpacity(0.65)),
                if (unread > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: JueviColors.carmesim,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Menu de perfil
// ──────────────────────────────────────────────
class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Equipe',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: JueviColors.bgCard,
      elevation: 8,
      onSelected: (route) => context.go(route),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: '/perfil',
          child: Row(children: [
            const Icon(Icons.person_outline, size: 18, color: JueviColors.lavanda),
            const SizedBox(width: 10),
            Text('Meu Perfil', style: JueviText.body(size: 13)),
          ]),
        ),
        PopupMenuItem(
          value: '/equipe',
          child: Row(children: [
            const Icon(Icons.groups_outlined, size: 18, color: JueviColors.ciano),
            const SizedBox(width: 10),
            Text('Equipe', style: JueviText.body(size: 13)),
          ]),
        ),
        PopupMenuItem(
          value: '/projeto',
          child: Row(children: [
            const Icon(Icons.folder_outlined, size: 18, color: JueviColors.tangerina),
            const SizedBox(width: 10),
            Text('Projeto Ativo', style: JueviText.body(size: 13)),
          ]),
        ),
      ],
      child: _ProfileAvatar(),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(left: 4),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _hovered
              ? JueviColors.carmesim
              : JueviColors.carmesim.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'Vi',
            style: JueviText.bodyBold(
              size: 13,
              color: _hovered ? Colors.white : JueviColors.carmesim,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Controles de janela
// ──────────────────────────────────────────────
class _WindowControl extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowControl({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  @override
  State<_WindowControl> createState() => _WindowControlState();
}

class _WindowControlState extends State<_WindowControl> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30, height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isClose
                    ? JueviColors.carmesim
                    : JueviColors.chumbo.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 15,
            color: _hovered && widget.isClose ? Colors.white : JueviColors.chumbo,
          ),
        ),
      ),
    );
  }
}
