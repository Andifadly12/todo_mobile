import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/primary_button.dart';
import '../../domain/category_repository.dart';
import '../category_cubit.dart';
import 'category_color_picker.dart';

class CategoryEditor extends StatefulWidget {
  const CategoryEditor({super.key, required this.cubit, this.category});
  final CategoryCubit cubit;
  final Category? category;
  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.category?.name);
  late String? color = widget.category?.color;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.category == null
                          ? 'Warna untuk rencanamu.'
                          : 'Edit kategori',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                enabled: !saving,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nama kategori',
                  hintText: 'Contoh: Pekerjaan',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Nama kategori wajib diisi.'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih warna',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              CategoryColorPicker(
                value: color,
                onChanged: saving ? null : (v) => setState(() => color = v),
              ),
              const SizedBox(height: 24),
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
                label: 'Simpan kategori',
                loading: saving,
                onPressed: () async {
                  if (!form.currentState!.validate()) return;
                  setState(() {
                    saving = true;
                    error = null;
                  });
                  final ok = await widget.cubit.save(
                    id: widget.category?.id,
                    name: name.text.trim(),
                    color: color,
                  );
                  if (!context.mounted) return;
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
