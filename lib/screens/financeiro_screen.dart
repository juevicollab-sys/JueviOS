import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

final _brl = NumberFormat.simpleCurrency(locale: 'pt_BR');

class FinanceiroScreen extends ConsumerWidget {
  const FinanceiroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receita = ref.watch(totalReceitaProvider);
    final despesa = ref.watch(totalDespesaProvider);
    final saldo   = ref.watch(saldoProvider);
    final async   = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SummaryCard('Receitas', _brl.format(receita), JueviColors.verde,    Icons.arrow_upward),
              const SizedBox(width: 16),
              _SummaryCard('Despesas', _brl.format(despesa), JueviColors.carmesim, Icons.arrow_downward),
              const SizedBox(width: 16),
              _SummaryCard('Saldo',    _brl.format(saldo),   JueviColors.ciano,    Icons.account_balance_wallet_outlined),
            ].map((w) => Expanded(child: w)).toList(),
          ),
          const SizedBox(height: 24),
          Text('TRANSAÇÕES RECENTES', style: JueviText.accent(size: 14)),
          const SizedBox(height: 12),
          async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro ao carregar transações', style: JueviText.label()),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Nenhuma transação ainda', style: JueviText.label()),
                  ),
                );
              }
              return Column(
                children: transactions.map((t) => _TransactionTile(t)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile(this.transaction);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.receita;
    final color = isIncome ? JueviColors.verde : JueviColors.carmesim;
    final dateStr = DateFormat('dd/MM').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(transaction.title, style: JueviText.body())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${_brl.format(transaction.value)}',
                style: JueviText.bodyBold(color: color),
              ),
              Text(dateStr, style: JueviText.label(size: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: JueviText.pageTitle(size: 24).copyWith(color: color)),
          Text(label, style: JueviText.label()),
        ],
      ),
    );
  }
}
