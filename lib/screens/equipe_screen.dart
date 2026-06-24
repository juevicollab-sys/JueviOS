import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EquipeScreen extends StatefulWidget {
  const EquipeScreen({super.key});

  @override
  State<EquipeScreen> createState() => _EquipeScreenState();
}

class _EquipeScreenState extends State<EquipeScreen> {
  int _page = 0;

  static const _pages = [
    [_vi, _ju],
    [_florzinha, _ursinho],
  ];

  @override
  Widget build(BuildContext context) {
    final members = _pages[_page];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 72, 24),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _CharCard(member: members[0])),
                    const SizedBox(width: 20),
                    Expanded(child: _CharCard(member: members[1])),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '2026',
                style: JueviText.accent(size: 20).copyWith(
                  color: JueviColors.chumbo.withOpacity(0.25),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        // Navigation arrow
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _page = (_page + 1) % _pages.length),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: JueviColors.bgCard,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: JueviColors.chumbo.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_right,
                    color: JueviColors.chumbo, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberData {
  final String name;
  final String role;
  final String archetype;
  final String charAsset;
  final Color color;
  final List<(String, double)> skills;

  const _MemberData({
    required this.name,
    required this.role,
    required this.archetype,
    required this.charAsset,
    required this.color,
    required this.skills,
  });
}

const _vi = _MemberData(
  name: 'Lucas Viegas',
  role: 'Direção Técnica & Audiovisual',
  archetype: 'Visionário · Rebelde',
  charAsset: 'assets/characters/char-motivacao-full.png',
  color: JueviColors.carmesim,
  skills: [
    ('Audiovisual', 0.95),
    ('Motion Design', 0.88),
    ('Flutter Dev', 0.80),
  ],
);

const _ju = _MemberData(
  name: 'Julia Macuco',
  role: 'Direção Criativa & Branding',
  archetype: 'Criadora · Cuidadora',
  charAsset: 'assets/characters/char-calma-full.png',
  color: JueviColors.lavanda,
  skills: [
    ('Branding', 0.96),
    ('Ilustração', 0.85),
    ('Estratégia de Marca', 0.88),
  ],
);

const _florzinha = _MemberData(
  name: 'Vontade',
  role: 'A energia que move',
  archetype: 'Entusiasmo · Criação',
  charAsset: 'assets/characters/char-vontade-full.png',
  color: JueviColors.tangerina,
  skills: [
    ('Motivação', 1.0),
    ('Brainstorm', 0.92),
    ('Execução', 0.87),
  ],
);

const _ursinho = _MemberData(
  name: 'Disciplina',
  role: 'A âncora do processo',
  archetype: 'Método · Consistência',
  charAsset: 'assets/characters/char-disciplina-full.png',
  color: JueviColors.verde,
  skills: [
    ('Planejamento', 0.94),
    ('Organização', 0.91),
    ('Entrega', 0.97),
  ],
);

class _CharCard extends StatelessWidget {
  final _MemberData member;
  const _CharCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JueviColors.bgCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: member.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Character (big)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: Image.asset(
                member.charAsset,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          // Info
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    member.name,
                    style: JueviText.pageTitle(size: 20)
                        .copyWith(color: member.color),
                  ),
                  const SizedBox(height: 2),
                  Text(member.role, style: JueviText.label()),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: member.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      member.archetype,
                      style:
                          JueviText.label(color: member.color, size: 11),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...member.skills.map((s) {
                    final (skill, value) = s;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(skill, style: JueviText.body(size: 12)),
                              Text(
                                '${(value * 100).toInt()}%',
                                style: JueviText.label(size: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor:
                                  member.color.withOpacity(0.1),
                              valueColor:
                                  AlwaysStoppedAnimation(member.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
