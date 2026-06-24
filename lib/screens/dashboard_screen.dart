import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/transaction.dart';
import '../providers/projects_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

final _brl = NumberFormat.simpleCurrency(locale: 'pt_BR');

// Receita mensal dos últimos 6 meses para o gráfico
final _monthlyChartProvider = Provider<List<FlSpot>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final monthly = <int, double>{};

  for (final t in transactions) {
    if (t.type == TransactionType.receita) {
      monthly[t.date.month] = (monthly[t.date.month] ?? 0) + t.value;
    }
  }

  return List.generate(6, (i) {
    final month = ((now.month - 5 + i - 1) % 12) + 1;
    return FlSpot(i.toDouble(), (monthly[month] ?? 0) / 1000);
  });
});

final _monthLabelsProvider = Provider<List<String>>((ref) {
  final now = DateTime.now();
  const abbr = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  return List.generate(6, (i) {
    final month = ((now.month - 5 + i - 1) % 12) + 1;
    return abbr[month];
  });
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects     = ref.watch(projectsProvider).valueOrNull ?? [];
    final receita      = ref.watch(totalReceitaProvider);
    final pendingTasks = ref.watch(pendingTasksProvider);

    final activeProjects = projects.where((p) =>
        p.status != ProjectStatus.entregue && p.status != ProjectStatus.arquivado).toList();
    final dueSoon = activeProjects.where((p) =>
        p.deadline != null &&
        p.deadline!.difference(DateTime.now()).inDays <= 7).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _BigStatCard(
                    label: 'Faturamento mensal',
                    value: _brl.format(receita),
                    sub: receita > 0 ? 'receita acumulada' : 'sem receitas ainda',
                    color: JueviColors.verde,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BigStatCard(
                    label: 'Projetos ativos',
                    value: '${activeProjects.length}',
                    sub: dueSoon > 0 ? '$dueSoon com prazo esta semana' : 'todos em dia',
                    color: JueviColors.tangerina,
                    icon: Icons.work_outline,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BigStatCard(
                    label: 'Tarefas pendentes',
                    value: '${pendingTasks.length}',
                    sub: pendingTasks.isEmpty ? 'tudo em dia!' : '${pendingTasks.length} para fazer',
                    color: JueviColors.carmesim,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            flex: 7,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(flex: 5, child: _ChartCard()),
                const SizedBox(width: 14),
                Expanded(flex: 3, child: _RecentCard()),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  const _BigStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: JueviText.pageTitle(size: 32).copyWith(color: color)),
              const SizedBox(height: 4),
              Text(label, style: JueviText.bodyBold(size: 13)),
              const SizedBox(height: 3),
              Text(sub, style: JueviText.label(size: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends ConsumerWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots  = ref.watch(_monthlyChartProvider);
    final months = ref.watch(_monthLabelsProvider);
    final receita = ref.watch(totalReceitaProvider);
    final maxY = spots.isEmpty ? 14.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: JueviColors.chumbo.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('FATURAMENTO ${DateTime.now().year}', style: JueviText.pageTitle(size: 18))),
              Text(_brl.format(receita), style: JueviText.bodyBold(size: 14, color: JueviColors.verde)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: JueviColors.chumbo.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(months[i], style: JueviText.label(size: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 5,
                minY: 0, maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty
                        ? [const FlSpot(0, 0), const FlSpot(5, 0)]
                        : spots,
                    isCurved: true,
                    color: JueviColors.carmesim,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: JueviColors.carmesim,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          JueviColors.carmesim.withOpacity(0.12),
                          JueviColors.carmesim.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends ConsumerWidget {
  const _RecentCard();

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
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final recent   = projects.take(5).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: JueviColors.chumbo.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROJETOS RECENTES', style: JueviText.accent(size: 12)),
          const SizedBox(height: 14),
          Expanded(
            child: recent.isEmpty
                ? Center(child: Text('Nenhum projeto ainda', style: JueviText.label()))
                : ListView.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      color: JueviColors.chumbo.withOpacity(0.06),
                    ),
                    itemBuilder: (_, i) {
                      final p = recent[i];
                      final color = _statusColor(p.status);
                      return Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(p.title, style: JueviText.body(size: 13))),
                          Text(_statusLabel(p.status), style: JueviText.label(size: 11, color: color)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
