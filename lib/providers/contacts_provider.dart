import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact.dart';
import 'supabase_provider.dart';

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Contact>> build() async {
    final client = ref.watch(supabaseClientProvider);
    if (client == null) return [];

    _channel = client
        .channel('public:contacts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contacts',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();

    ref.onDispose(() => _channel?.unsubscribe());

    final data = await client
        .from('contacts')
        .select()
        .order('name', ascending: true);

    return data.map((e) => Contact.fromJson(e)).toList();
  }

  Future<void> create({
    required String name,
    String? email,
    String? phone,
    String? company,
    ContactStatus status = ContactStatus.lead,
    String? notes,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('contacts').insert({
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'status': status.value,
      'notes': notes,
    });
  }

  Future<void> updateContact(Contact contact) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('contacts').update(contact.toJson()).eq('id', contact.id);
  }

  Future<void> updateStatus(String id, ContactStatus status) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('contacts').update({'status': status.value}).eq('id', id);
  }

  Future<void> delete(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    await client.from('contacts').delete().eq('id', id);
  }
}

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(ContactsNotifier.new);
