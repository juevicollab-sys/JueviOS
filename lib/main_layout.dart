import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/colors.dart';
import 'theme/text_styles.dart';
import 'widgets/nav_pill.dart';
import 'widgets/app_header.dart';
import 'core/nav_constants.dart';

export 'core/nav_constants.dart';

const kBreakpointMobile = 600.0;
const kBreakpointTablet = 900.0;

final currentPageIndexProvider = StateProvider<int>((ref) => 0);

const _allTitles = {
  '/dashboard':     'DASHBOARD',
  '/atividade':     'ATIVIDADE',
  '/crm':           'CRM',
  '/financeiro':    'FINANCEIRO',
  '/portfolio':     'PORTFÓLIO',
  '/notificacoes':  'NOTIFICAÇÕES',
  '/projeto':       'PROJETO',
  '/redes-sociais': 'REDES SOCIAIS',
  '/perfil':        'PERFIL',
  '/equipe':        'EQUIPE',
};

// Routes that manage their own bottom section (no shared workspace)
const _noWorkspaceRoutes = {'/projeto', '/equipe'};

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({super.key, required this.child, required this.currentRoute});

  int get _currentIndex {
    final idx = navRoutes.indexOf(currentRoute);
    return idx < 0 ? 0 : idx;
  }

  String get _currentTitle => _allTitles[currentRoute] ?? 'STUDIO OS';
  bool get _showWorkspace => !_noWorkspaceRoutes.contains(currentRoute);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kBreakpointMobile) {
          return _MobileLayout(
            child: child,
            currentIndex: _currentIndex,
            title: _currentTitle,
            currentRoute: currentRoute,
            onNavTap: (i) => context.go(navRoutes[i]),
          );
        } else if (constraints.maxWidth < kBreakpointTablet) {
          return _TabletLayout(
            child: child,
            currentIndex: _currentIndex,
            title: _currentTitle,
            currentRoute: currentRoute,
            onNavTap: (i) => context.go(navRoutes[i]),
          );
        } else {
          return _DesktopLayout(
            child: child,
            currentIndex: _currentIndex,
            title: _currentTitle,
            currentRoute: currentRoute,
            onNavTap: (i) => context.go(navRoutes[i]),
            showWorkspace: _showWorkspace,
          );
        }
      },
    );
  }
}

// ──────────────────────────────────────────────
//  DESKTOP
// ──────────────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final String currentRoute;
  final ValueChanged<int> onNavTap;
  final bool showWorkspace;

  static const _kHeaderHeight = 80.0;
  static const _kNavWidth     = 68.0;
  static const _kWorkspace    = 210.0;

  const _DesktopLayout({
    required this.child,
    required this.currentIndex,
    required this.title,
    required this.currentRoute,
    required this.onNavTap,
    required this.showWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JueviColors.bgMain,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left nav column ──
          SizedBox(
            width: _kNavWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: _kHeaderHeight),
              child: NavPill(currentIndex: currentIndex, onTap: onNavTap),
            ),
          ),
          // ── Content + workspace ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: title,
                  currentRoute: currentRoute,
                  layoutType: LayoutType.desktop,
                  height: _kHeaderHeight,
                ),
                Expanded(
                  child: showWorkspace
                      ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Page content (clipped to the area above workspace)
                            Positioned.fill(
                              bottom: _kWorkspace,
                              child: ClipRect(child: child),
                            ),
                            // Bottom workspace zone
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: _kWorkspace,
                              child: const _BottomWorkspace(),
                            ),
                          ],
                        )
                      : ClipRect(child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  BOTTOM WORKSPACE ZONE
// ──────────────────────────────────────────────
class _BottomWorkspace extends StatefulWidget {
  const _BottomWorkspace();

  @override
  State<_BottomWorkspace> createState() => _BottomWorkspaceState();
}

class _BottomWorkspaceState extends State<_BottomWorkspace> {
  final List<(String, bool)> _items = [
    ('Revisar briefing', false),
    ('Enviar proposta', true),
    ('Editar vídeo #3', false),
    ('Follow-up Helena', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background + top border
        Container(
          decoration: BoxDecoration(
            color: JueviColors.bgMain,
            border: Border(
              top: BorderSide(
                color: JueviColors.chumbo.withOpacity(0.09),
                width: 1.5,
              ),
            ),
          ),
        ),
        // Content row (left gap for mascot)
        Positioned.fill(
          left: 200, // leaves room for the character
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Projeto ativo card
                Flexible(
                  flex: 2,
                  child: _WorkspaceInfoCard(),
                ),
                const SizedBox(width: 14),
                // Checklist sticky
                Flexible(
                  flex: 3,
                  child: _ChecklistSticky(
                    items: _items,
                    onToggle: (i) => setState(() {
                      final (label, done) = _items[i];
                      _items[i] = (label, !done);
                    }),
                  ),
                ),
                const SizedBox(width: 14),
                // CTA button
                Expanded(
                  flex: 2,
                  child: _WorkspaceCta(),
                ),
              ],
            ),
          ),
        ),
        // Mascot character (overflows upward)
        Positioned(
          bottom: 0,
          left: 10,
          child: IgnorePointer(
            child: Image.asset(
              'assets/characters/char-motivacao-full.png',
              height: 210,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: JueviColors.chumbo.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PROJETO ATIVO',
            style: JueviText.accent(size: 9).copyWith(
              color: JueviColors.chumbo.withOpacity(0.45),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text('Agrojardim', style: JueviText.pageTitle(size: 15)),
          const SizedBox(height: 4),
          Text('Helena Barcellos', style: JueviText.label(size: 11)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.68,
              backgroundColor: JueviColors.verde.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(JueviColors.verde),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '68% concluído',
            style: JueviText.label(size: 10, color: JueviColors.verde),
          ),
        ],
      ),
    );
  }
}

class _ChecklistSticky extends StatelessWidget {
  final List<(String, bool)> items;
  final ValueChanged<int> onToggle;

  const _ChecklistSticky({required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: JueviColors.mostarda,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: JueviColors.mostarda.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHECKLIST',
            style: JueviText.accent(size: 11).copyWith(
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (i) {
                final (label, done) = items[i];
                return GestureDetector(
                  onTap: () => onToggle(i),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: done
                              ? Colors.white.withOpacity(0.9)
                              : Colors.transparent,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: done
                            ? const Icon(Icons.check,
                                size: 10, color: JueviColors.mostarda)
                            : null,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white
                                .withOpacity(done ? 0.45 : 0.92),
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                            decorationColor:
                                Colors.white.withOpacity(0.45),
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCta extends StatefulWidget {
  @override
  State<_WorkspaceCta> createState() => _WorkspaceCtaState();
}

class _WorkspaceCtaState extends State<_WorkspaceCta> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered
                ? JueviColors.tangerina.withOpacity(0.9)
                : JueviColors.tangerina,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: JueviColors.tangerina.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              'NOVA\nTAREFA',
              textAlign: TextAlign.center,
              style: JueviText.accent(size: 18, color: Colors.white).copyWith(
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  TABLET
// ──────────────────────────────────────────────
class _TabletLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final String currentRoute;
  final ValueChanged<int> onNavTap;

  const _TabletLayout({
    required this.child,
    required this.currentIndex,
    required this.title,
    required this.currentRoute,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JueviColors.bgMain,
      body: Row(
        children: [
          _TabletRail(currentIndex: currentIndex, onTap: onNavTap),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: title,
                  currentRoute: currentRoute,
                  layoutType: LayoutType.tablet,
                  height: 56,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  MOBILE
// ──────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final String currentRoute;
  final ValueChanged<int> onNavTap;

  const _MobileLayout({
    required this.child,
    required this.currentIndex,
    required this.title,
    required this.currentRoute,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JueviColors.bgMain,
      body: Column(
        children: [
          AppHeader(
            title: title,
            currentRoute: currentRoute,
            layoutType: LayoutType.mobile,
            height: 56,
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentIndex: currentIndex, onTap: onNavTap),
    );
  }
}

// ──────────────────────────────────────────────
//  TABLET RAIL
// ──────────────────────────────────────────────
class _TabletRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabletRail({required this.currentIndex, required this.onTap});

  static const _icons = [
    'assets/characters/icon-vontade.png',
    'assets/characters/icon-motivacao.png',
    'assets/characters/icon-calma.png',
    'assets/characters/icon-disciplina.png',
    'assets/characters/icon-insight.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      color: JueviColors.navPill,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_icons.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(6),
              decoration: active
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              child: Image.asset(_icons[i], width: 32, height: 32),
            ),
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  MOBILE BOTTOM NAV
// ──────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _icons = [
    'assets/characters/icon-vontade.png',
    'assets/characters/icon-motivacao.png',
    'assets/characters/icon-calma.png',
    'assets/characters/icon-disciplina.png',
    'assets/characters/icon-insight.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: JueviColors.navPill,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedScale(
              scale: active ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: active
                    ? BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : null,
                child: Image.asset(_icons[i],
                    width: active ? 40 : 32, height: active ? 40 : 32),
              ),
            ),
          );
        }),
      ),
    );
  }
}
