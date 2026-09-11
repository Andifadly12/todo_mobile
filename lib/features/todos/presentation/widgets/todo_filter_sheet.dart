import 'package:flutter/material.dart';

import '../../../categories/domain/category_repository.dart';
import '../todo_cubit.dart';
import 'todo_editor.dart';

class TodoFilterSheet extends StatefulWidget {
  const TodoFilterSheet({
    super.key,
    required this.cubit,
    required this.categories,
  });
  final TodoCubit cubit;
  final CategoryRepository categories;
  @override
  State<TodoFilterSheet> createState() => _State();
}

class _State extends State<TodoFilterSheet> {
  late final search = TextEditingController(text: widget.cubit.search);
  late String? priority = widget.cubit.priority,
      category = widget.cubit.categoryId;
  late bool? completed = widget.cubit.completed;
  late final categories = widget.categories.list();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      16,
      24,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Temukan tugasmu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: search,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Cari judul'),
          ),
          DropdownButtonFormField<String>(
            initialValue: priority ?? '',
            decoration: const InputDecoration(labelText: 'Prioritas'),
            items: [
              const DropdownMenuItem(value: '', child: Text('Semua')),
              ...priorityLabels.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: (v) => priority = v == '' ? null : v,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Category>>(
            future: categories,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                initialValue: category ?? '',
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  helperText: snapshot.hasError
                      ? 'Kategori gagal dimuat. Filter saat ini dipertahankan.'
                      : null,
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Semua kategori'),
                  ),
                  if (category != null && !items.any((e) => e.id == category))
                    DropdownMenuItem(
                      value: category,
                      child: const Text('Kategori saat ini'),
                    ),
                  ...items.map(
                    (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                  ),
                ],
                onChanged: snapshot.hasData
                    ? (v) => category = v == '' ? null : v
                    : null,
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: completed?.toString() ?? '',
            decoration: const InputDecoration(labelText: 'Penyelesaian'),
            items: const [
              DropdownMenuItem(value: '', child: Text('Semua')),
              DropdownMenuItem(value: 'true', child: Text('Selesai')),
              DropdownMenuItem(value: 'false', child: Text('Belum selesai')),
            ],
            onChanged: (v) => completed = v == '' ? null : v == 'true',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              widget.cubit.applyFilters(
                search: search.text.trim().isEmpty ? null : search.text.trim(),
                priority: priority,
                categoryId: category,
                completed: completed,
              );
              Navigator.pop(context);
            },
            child: const Text('Terapkan filter'),
          ),
          TextButton(
            onPressed: () {
              widget.cubit.applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Hapus filter tambahan'),
          ),
        ],
      ),
    ),
  );
}
