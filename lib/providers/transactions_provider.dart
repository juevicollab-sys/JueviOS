import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'supabase_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Transaction>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:transactions')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('transactions')
        .select('*, projects(title)')
        .order('date', ascending: false);

    return data.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> create({
    required String title,
    required TransactionType type,
    required double value,
    required DateTime date,
    String? category,
    String? projectId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('transactions').insert({
      'title': title,
      'type': type.value,
      'value': value,
      'date': date.toIso8601String().split('T').first,
      'category': category,
      'project_id': projectId,
    });
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('transactions').delete().eq('id', id);
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
        TransactionsNotifier.new);

// Providers derivados para o Dashboard e Financeiro
final totalReceitaProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions
      .where((t) => t.type == TransactionType.receita)
      .fold(0.0, (sum, t) => sum + t.value);
});

final totalDespesaProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions
      .where((t) => t.type == TransactionType.despesa)
      .fold(0.0, (sum, t) => sum + t.value);
});

final saldoProvider = Provider<double>((ref) {
  return ref.watch(totalReceitaProvider) - ref.watch(totalDespesaProvider);
});
