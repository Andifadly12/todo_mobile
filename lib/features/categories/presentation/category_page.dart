import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/api_category_repository.dart';
import '../domain/category_repository.dart';
import 'category_cubit.dart';
import 'widgets/category_color_picker.dart';
import 'widgets/category_editor.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        CategoryCubit(ApiCategoryRepository(context.read<ApiClient>()))..load(),
    child: const _CategoryView(),
  );
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();
  void edit(BuildContext context, [Category? category]) {
    final cubit = context.read<CategoryCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (_) => CategoryEditor(cubit: cubit, category: category),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<CategoryCubit, CategoryState>(
    builder: (context, state) {
      final cubit = context.read<CategoryCubit>();
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'add-category',
          onPressed: state.busy ? null : () => edit(context),
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Kategori baru'),
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: AppColors.brown),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Muat ulang kategori',
                      onPressed: state.busy ? null : cubit.load,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Setiap rencana,\npunya ruangnya.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${state.items.length} kategori · Kelompokkan tugas dengan warna yang kamu suka.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (state.busy) const LinearProgressIndicator(),
                if (state.error != null)
                  Column(
                    children: [
                      Text(state.error!),
                      TextButton(
                        onPressed: state.busy ? null : cubit.load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                if (state.items.isEmpty && !state.busy && state.error == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 64,
                          color: AppColors.brown,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Mulai dengan satu kategori.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pekerjaan, pribadi, atau ide-ide kecilmu.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                for (final category in state.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: categoryColor(category.color)
                              .withValues(alpha: .15),
                          child: Icon(
                            Icons.folder_outlined,
                            color: categoryColor(category.color),
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Ketuk untuk mengedit'),
                        onTap: state.busy
                            ? null
                            : () => edit(context, category),
                        trailing: PopupMenuButton<String>(
                          enabled: !state.busy,
                          tooltip: 'Opsi kategori',
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              edit(context, category);
                              return;
                            }
                            final yes = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus kategori?'),
                                content: Text(
                                  'Hapus kategori “${category.name}”? ',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (yes == true && !cubit.isClosed) {
                              await cubit.delete(category.id);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
