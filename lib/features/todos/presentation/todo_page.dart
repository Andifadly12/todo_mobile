import '../../ai/presentation/ask_ai_page.dart';
import '../../ai/data/api_ai_repository.dart';
import '../../ai/presentation/ai_prompt_sheet.dart';
import '../../categories/data/api_category_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/api_todo_repository.dart';
import '../domain/todo_repository.dart';
import 'todo_cubit.dart';
import 'widgets/todo_card.dart';
import 'widgets/todo_editor.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        TodoCubit(ApiTodoRepository(context.read<ApiClient>()))..load(),
    child: const _TodoView(),
  );
}

class _TodoView extends StatelessWidget {
  const _TodoView();
  Future<void> edit(BuildContext context, {Todo? todo, Todo? draft}) async {
    final cubit = context.read<TodoCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (context) => Stack(
        children: [
          TodoEditor(
            cubit: cubit,
            todo: todo,
            draft: draft,
            categories: ApiCategoryRepository(context.read<ApiClient>()),
          ),
          Positioned(
            right: 12,
            top: 0,
            child: IconButton(
              tooltip: 'Tutup',
              onPressed: () {
                if (!cubit.state.busy) Navigator.maybePop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TodoCubit, TodoState>(
    listenWhen: (a, b) => a.error != b.error,
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error!)));
      }
    },
    builder: (context, state) {
      final cubit = context.read<TodoCubit>();
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.busy ? null : () => edit(context),
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Tugas baru'),
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => cubit.load(status: state.status),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    const Icon(Icons.spa_outlined, color: AppColors.brown),
                    const SizedBox(width: 8),
                    const Text(
                      'ruang.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Muat ulang tugas',
                      onPressed: state.busy
                          ? null
                          : () => cubit.load(status: state.status),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Sedikit demi sedikit,',
                  style: TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const Text(
                  'jadi lebih berarti.',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF825B42), Color(0xFFAC8567)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.total} tugas${state.status == null ? '' : ' · ${statusLabels[state.status]}'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Satu langkah kecil hari ini.\nBeri ruang untuk hal yang penting.',
                              style: TextStyle(
                                color: Color(0xFFF4E7DC),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 48,
                        color: Color(0xFFECD5BC),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Tanya AI'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AskAiPage(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Buat tugas dengan AI'),
                    onPressed: state.busy
                        ? null
                        : () async {
                            final repository = ApiAiRepository(
                              context.read<ApiClient>(),
                            );
                            final draft = await showModalBottomSheet<Todo>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (_) =>
                                  AiPromptSheet(repository: repository),
                            );
                            if (context.mounted && draft != null) {
                              await edit(context, draft: draft);
                            }
                          },
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in {
                        '': 'Semua',
                        ...statusLabels,
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: (state.status ?? '') == entry.key,
                            onSelected: state.busy
                                ? null
                                : (_) => cubit.load(
                                    status: entry.key.isEmpty
                                        ? null
                                        : entry.key,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (state.busy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Text(state.error!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: state.busy
                              ? null
                              : () => cubit.load(status: state.status),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                if (state.items.isEmpty && !state.busy && state.error == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome_outlined,
                          size: 56,
                          color: AppColors.brown,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ruang untuk rencana baru.',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.status == null
                              ? 'Tambahkan tugas pertamamu. Mulai dari yang kecil.'
                              : 'Belum ada tugas dengan status ini.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                for (final todo in state.items)
                  TodoCard(
                    todo: todo,
                    enabled: !state.busy,
                    onEdit: () => edit(context, todo: todo),
                    onToggle: () => cubit.save({
                      'status': todo.status == 'COMPLETED'
                          ? 'TODO'
                          : 'COMPLETED',
                    }, id: todo.id),
                    onDelete: () async {
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus tugas?'),
                          content: Text('“${todo.title}” akan dihapus.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (yes == true && !cubit.isClosed) {
                        await cubit.remove(todo.id);
                      }
                    },
                  ),
                if (state.hasMore)
                  TextButton(
                    onPressed: state.busy ? null : () => cubit.load(more: true),
                    child: const Text('Muat tugas lainnya'),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
