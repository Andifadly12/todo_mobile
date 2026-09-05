import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/todo_repository.dart';
import 'todo_editor.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    this.enabled = true,
  });
  final Todo todo;
  final VoidCallback onEdit, onToggle, onDelete;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final done = todo.status == 'COMPLETED';
    final overdue =
        todo.dueAt != null &&
        todo.dueAt!.isBefore(DateTime.now()) &&
        !done &&
        todo.status != 'CANCELLED';
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.cream),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: enabled ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: done ? 'Tandai belum selesai' : 'Tandai selesai',
                onPressed: enabled ? onToggle : null,
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? AppColors.muted : AppColors.ink,
                      ),
                    ),
                    if (todo.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: todo.priority == 'HIGH'
                                ? const Color(0xFFF9E5DD)
                                : AppColors.cream,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priorityLabels[todo.priority] ?? todo.priority,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          statusLabels[todo.status] ?? todo.status,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    if (todo.dueAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '${overdue ? 'Terlambat · ' : ''}${dateLabel(todo.dueAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: overdue
                                ? Theme.of(context).colorScheme.error
                                : AppColors.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: enabled,
                tooltip: 'Opsi tugas',
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit tugas')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus tugas')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
