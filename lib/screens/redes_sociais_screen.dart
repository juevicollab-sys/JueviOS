import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RedesSociaisScreen extends ConsumerStatefulWidget {
  const RedesSociaisScreen({super.key});

  @override
  ConsumerState<RedesSociaisScreen> createState() => _RedesSociaisScreenState();
}

class _RedesSociaisScreenState extends ConsumerState<RedesSociaisScreen> {
  int? _selectedDay;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  static const _legend = [
    ('IG', 'Instagram',  JueviColors.carmesim),
    ('TT', 'TikTok',     JueviColors.chumbo),
    ('LI', 'LinkedIn',   JueviColors.lavanda),
    ('YT', 'YouTube',    JueviColors.verde),
    ('TH', 'Threads',    JueviColors.tangerina),
  ];

  String _networkCode(SocialNetwork n) => switch (n) {
        SocialNetwork.instagram => 'IG',
        SocialNetwork.tiktok    => 'TT',
        SocialNetwork.linkedin  => 'LI',
        SocialNetwork.youtube   => 'YT',
        SocialNetwork.threads   => 'TH',
      };

  Color _networkColor(SocialNetwork n) => switch (n) {
        SocialNetwork.instagram => JueviColors.carmesim,
        SocialNetwork.tiktok    => JueviColors.chumbo,
        SocialNetwork.linkedin  => JueviColors.lavanda,
        SocialNetwork.youtube   => JueviColors.verde,
        SocialNetwork.threads   => JueviColors.tangerina,
      };

  String _relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(date.year, date.month, date.day).difference(today).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff < 0) return 'Publicado';
    return 'em $diff dias';
  }

  @override
  Widget build(BuildContext context) {
    final postsByDate = ref.watch(postsByDateProvider);
    final allPosts    = ref.watch(postsProvider).valueOrNull ?? [];

    final year         = _month.year;
    final month        = _month.month;
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final daysInMonth  = DateTime(year, month + 1, 0).day;
    final monthNames   = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                          'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    final today = DateTime.now().day;
    final isCurrentMonth = _month.year == DateTime.now().year && _month.month == DateTime.now().month;

    final upcoming = allPosts
        .where((p) => !p.scheduledDate.isBefore(DateTime.now()))
        .take(5)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: _legend.map((item) {
              final (code, name, color) = item;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(code, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(name, style: JueviText.label()),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Month nav
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                child: const Icon(Icons.chevron_left, size: 22),
              ),
              const SizedBox(width: 8),
              Text('${monthNames[month].toUpperCase()} $year', style: JueviText.pageTitle(size: 26)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                child: const Icon(Icons.chevron_right, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day-of-week headers
          Row(
            children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                .map((d) => Expanded(child: Center(child: Text(d, style: JueviText.label(size: 11)))))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstWeekday) return const SizedBox();
              final day = i - firstWeekday + 1;
              final posts = postsByDate[DateTime(year, month, day)];
              final isSelected = _selectedDay == day;
              final isToday = isCurrentMonth && day == today;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day == _selectedDay ? null : day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? JueviColors.carmesim.withOpacity(0.12)
                        : isToday
                            ? JueviColors.bgCard
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: JueviColors.carmesim, width: 1.5)
                        : isSelected
                            ? Border.all(color: JueviColors.carmesim.withOpacity(0.4))
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: JueviText.body(size: 12, color: isToday ? JueviColors.carmesim : null)
                            .copyWith(fontWeight: isToday ? FontWeight.w700 : null),
                      ),
                      if (posts != null && posts.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: posts.take(3).map((p) => Container(
                            width: 5, height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(color: _networkColor(p.network), shape: BoxShape.circle),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text('PRÓXIMAS PUBLICAÇÕES', style: JueviText.accent(size: 16)),
          const SizedBox(height: 12),

          if (upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Nenhum post agendado', style: JueviText.label()),
            )
          else
            ...upcoming.map((post) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: JueviColors.bgCard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _networkColor(post.network),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _networkCode(post.network),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(post.title, style: JueviText.body(size: 13))),
                  Text(_relativeDay(post.scheduledDate), style: JueviText.label(size: 11)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
