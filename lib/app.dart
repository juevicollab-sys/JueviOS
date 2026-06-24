import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_layout.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/atividade_screen.dart';
import 'screens/crm_screen.dart';
import 'screens/financeiro_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/notificacoes_screen.dart';
import 'screens/projeto_screen.dart';
import 'screens/redes_sociais_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/equipe_screen.dart';
import 'theme/colors.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        currentRoute: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: '/dashboard',     builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/atividade',     builder: (_, __) => const AtividadeScreen()),
        GoRoute(path: '/crm',           builder: (_, __) => const CrmScreen()),
        GoRoute(path: '/financeiro',    builder: (_, __) => const FinanceiroScreen()),
        GoRoute(path: '/portfolio',     builder: (_, __) => const PortfolioScreen()),
        GoRoute(path: '/notificacoes',  builder: (_, __) => const NotificacoesScreen()),
        GoRoute(path: '/projeto',       builder: (_, __) => const ProjetoScreen()),
        GoRoute(path: '/redes-sociais', builder: (_, __) => const RedesSociaisScreen()),
        GoRoute(path: '/perfil',        builder: (_, __) => const PerfilScreen()),
        GoRoute(path: '/equipe',        builder: (_, __) => const EquipeScreen()),
      ],
    ),
  ],
);

class JueviApp extends StatelessWidget {
  const JueviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ju&Vi Studio OS',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: JueviColors.carmesim,
          surface: JueviColors.bgMain,
        ),
        scaffoldBackgroundColor: JueviColors.bgMain,
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
      ),
    );
  }
}
