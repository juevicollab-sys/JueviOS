import 'package:flutter/material.dart';
import '../theme/colors.dart';

const _navIcons = [
  ('assets/characters/icon-vontade.png',    'Dashboard'),
  ('assets/characters/icon-motivacao.png',  'Atividade'),
  ('assets/characters/icon-calma.png',      'CRM'),
  ('assets/characters/icon-disciplina.png', 'Financeiro'),
  ('assets/characters/icon-insight.png',    'Portfólio'),
];

class NavPill extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavPill({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Container(
        decoration: BoxDecoration(
          color: JueviColors.navPill,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_navIcons.length, (i) {
            final (icon, label) = _navIcons[i];
            final active = i == currentIndex;
            return Tooltip(
              message: label,
              preferBelow: false,
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  width: 46,
                  height: 46,
                  decoration: active
                      ? BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(23),
                        )
                      : null,
                  child: Center(
                    child: Image.asset(icon, width: 30, height: 30),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
