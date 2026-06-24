import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CrmScreen extends ConsumerStatefulWidget {
  const CrmScreen({super.key});

  @override
  ConsumerState<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends ConsumerState<CrmScreen> {
  String _filter = 'todos';
  String _search = '';

  Color _statusColor(ContactStatus s) => switch (s) {
        ContactStatus.cliente  => JueviColors.verde,
        ContactStatus.lead     => JueviColors.tangerina,
        ContactStatus.prospect => JueviColors.lavanda,
        ContactStatus.inativo  => JueviColors.chumbo.withOpacity(0.3),
      };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(contactsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: JueviText.body(size: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar contato...',
                    hintStyle: JueviText.label(),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: JueviColors.bgCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    isDense: true,
                    constraints: const BoxConstraints(maxHeight: 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ..._buildFilters(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro ao carregar contatos', style: JueviText.label())),
              data: (contacts) {
                final filtered = contacts.where((c) {
                  final matchFilter = _filter == 'todos' || c.status.value == _filter;
                  final matchSearch = c.name.toLowerCase().contains(_search.toLowerCase()) ||
                      (c.company ?? '').toLowerCase().contains(_search.toLowerCase());
                  return matchFilter && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _search.isNotEmpty ? 'Nenhum resultado para "$_search"' : 'Nenhum contato ainda',
                      style: JueviText.label(),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ContactTile(
                        contact: filtered[i],
                        statusColor: _statusColor(filtered[i].status),
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
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilters() {
    const opts = ['todos', 'cliente', 'lead', 'prospect'];
    return opts.map((o) {
      final active = _filter == o;
      return GestureDetector(
        onTap: () => setState(() => _filter = o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? JueviColors.carmesim : JueviColors.bgCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            o,
            style: JueviText.label(
              color: active ? Colors.white : null,
              size: 12,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _ContactTile extends StatelessWidget {
  final Contact contact;
  final Color statusColor;

  const _ContactTile({required this.contact, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final initials = contact.name.trim().split(' ')
        .take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: JueviColors.chumbo.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: statusColor.withOpacity(0.15),
            child: Text(
              initials,
              style: JueviText.bodyBold(size: 16, color: statusColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(contact.name, style: JueviText.bodyBold()),
                const SizedBox(height: 3),
                Text(contact.company ?? '', style: JueviText.label()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              contact.status.value,
              style: JueviText.label(size: 11, color: statusColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
