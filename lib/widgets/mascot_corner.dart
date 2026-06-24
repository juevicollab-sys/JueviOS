import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_item.dart';
import '../providers/tasks_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class MascotCorner extends ConsumerWidget {
  const MascotCorner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingTasksProvider);
    final shown   = pending.take(4).toList();

    return SizedBox(
      width: 360,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 55, left: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/characters/char-cloud.png',
                width: 90,
                opacity: const AlwaysStoppedAnimation(0.7),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 18,
            child: IgnorePointer(
              child: Image.asset(
                'assets/characters/char-motivacao-full.png',
                width: 104,
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 136,
            child: _ChecklistPanel(
              items: shown,
              onToggle: (task) => ref
                  .read(tasksProvider.notifier)
                  .toggle(task.id, task.isDone),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistPanel extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onToggle;

  const _ChecklistPanel({required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: BoxDecoration(
        color: JueviColors.mostarda,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CHECKLIST',
            style: JueviText.accent(size: 11).copyWith(
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'Tudo em dia!',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            )
          else
            ...items.map((task) => GestureDetector(
                  onTap: () => onToggle(task),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: task.isDone
                                ? Colors.white.withOpacity(0.9)
                                : Colors.transparent,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.7),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: task.isDone
                              ? const Icon(Icons.check, size: 10, color: JueviColors.mostarda)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(task.isDone ? 0.45 : 0.92),
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white.withOpacity(0.45),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
