import '../../../categories/domain/category_repository.dart';

import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/primary_button.dart';
import '../../domain/todo_repository.dart';
import '../todo_cubit.dart';

const statusLabels = {
  'TODO': 'Belum mulai',
  'IN_PROGRESS': 'Dikerjakan',
  'COMPLETED': 'Selesai',
  'CANCELLED': 'Dibatalkan',
};
const priorityLabels = {'LOW': 'Rendah', 'MEDIUM': 'Sedang', 'HIGH': 'Tinggi'};
String dateLabel(DateTime date) =>
    '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class TodoEditor extends StatefulWidget {
  const TodoEditor({
    super.key,
    required this.cubit,
    this.todo,
    this.categories,
  });
  final TodoCubit cubit;
  final Todo? todo;
  final CategoryRepository? categories;
  @override
  State<TodoEditor> createState() => _TodoEditorState();
}

class _TodoEditorState extends State<TodoEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.todo?.title);
  late final description = TextEditingController(
    text: widget.todo?.description,
  );
  late String status = widget.todo?.status ?? 'TODO';
  late String priority = widget.todo?.priority ?? 'MEDIUM';
  late DateTime? due = widget.todo?.dueAt;
  late DateTime? reminder = widget.todo?.reminderAt;
  late String? categoryId = widget.todo?.categoryId;
  List<Category> categories = [];
  bool categoriesLoading = false;
  String? categoryError;
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (widget.categories == null) return;
    setState(() {
      categoriesLoading = true;
      categoryError = null;
    });
    try {
      final values = await widget.categories!.list();
      if (mounted) setState(() => categories = values);
    } catch (_) {
      if (mounted) {
        setState(() => categoryError = 'Kategori belum dapat dimuat.');
      }
    } finally {
      if (mounted) setState(() => categoriesLoading = false);
    }
  }

  bool saving = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pick(bool isDue) async {
    final initial = (isDue ? due : reminder) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isDue) {
        due = value;
      } else {
        reminder = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.todo == null
                    ? 'Satu langkah baru.'
                    : 'Rapikan rencanamu.',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: title,
                enabled: !saving,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  hintText: 'Apa yang ingin kamu selesaikan?',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Judul wajib diisi.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: description,
                enabled: !saving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tambahkan detail, jika perlu',
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statusLabels.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: saving ? null : (v) => setState(() => status = v!),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Prioritas'),
                items: priorityLabels.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: saving ? null : (v) => setState(() => priority = v!),
              ),
              const SizedBox(height: 12),
              if (widget.categories != null) ...[
                const SizedBox(height: 16),
                if (categoriesLoading) const LinearProgressIndicator(),
                if (categoryError != null)
                  TextButton(
                    onPressed: loadCategories,
                    child: Text('$categoryError Coba lagi'),
                  ),
                DropdownButtonFormField<String>(
                  key: ValueKey('${categories.length}:$categoryId'),
                  initialValue: categoryId ?? '',
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Tanpa kategori'),
                    ),
                    if (categoryId != null &&
                        !categories.any((e) => e.id == categoryId))
                      DropdownMenuItem(
                        value: categoryId,
                        child: const Text('Kategori saat ini'),
                      ),
                    ...categories.map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                    ),
                  ],
                  onChanged:
                      saving || categoriesLoading || categoryError != null
                      ? null
                      : (v) => setState(() => categoryId = v == '' ? null : v),
                ),
              ],
              for (final isDue in [true, false])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDue
                        ? Icons.calendar_today_outlined
                        : Icons.notifications_none,
                  ),
                  title: Text(isDue ? 'Tenggat waktu' : 'Waktu pengingat'),
                  subtitle: Text(
                    (isDue ? due : reminder) == null
                        ? 'Belum diatur'
                        : dateLabel((isDue ? due : reminder)!),
                  ),
                  onTap: saving ? null : () => pick(isDue),
                  trailing: (isDue ? due : reminder) == null
                      ? const Icon(Icons.chevron_right)
                      : IconButton(
                          tooltip: 'Hapus waktu',
                          onPressed: saving
                              ? null
                              : () => setState(() {
                                  if (isDue) {
                                    due = null;
                                  } else {
                                    reminder = null;
                                  }
                                }),
                          icon: const Icon(Icons.close),
                        ),
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              PrimaryButton(
                label: 'Simpan tugas',
                loading: saving,
                onPressed: () async {
                  if (!form.currentState!.validate()) return;
                  if (due != null &&
                      reminder != null &&
                      reminder!.isAfter(due!)) {
                    setState(
                      () => error = 'Pengingat harus sebelum tenggat waktu.',
                    );
                    return;
                  }
                  setState(() {
                    saving = true;
                    error = null;
                  });
                  final ok = await widget.cubit.save({
                    'title': title.text.trim(),
                    'categoryId': categoryId,
                    'description': description.text.trim(),
                    'status': status,
                    'priority': priority,
                    'dueAt': due?.toUtc().toIso8601String(),
                    'reminderAt': reminder?.toUtc().toIso8601String(),
                  }, id: widget.todo?.id);
                  if (!mounted || !context.mounted) return;
                  setState(() => saving = false);
                  if (ok) {
                    Navigator.pop(context);
                  } else {
                    setState(() => error = widget.cubit.state.error);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
