import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../data/api_notification_repository.dart';
import 'notification_cubit.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        NotificationCubit(ApiNotificationRepository(context.read<ApiClient>()))
          ..load(),
    child: const _View(),
  );
}

class _View extends StatelessWidget {
  const _View();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final cubit = context.read<NotificationCubit>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifikasi'),
              actions: [
                IconButton(
                  tooltip: 'Tandai semua dibaca',
                  onPressed: state.busy ? null : () => cubit.read(),
                  icon: const Icon(Icons.done_all),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
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
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 60,
                            color: AppColors.brown,
                          ),
                          SizedBox(height: 16),
                          Text('Belum ada notifikasi.'),
                        ],
                      ),
                    ),
                  for (final item in state.items)
                    Card(
                      color: item.isRead ? Colors.white : AppColors.cream,
                      elevation: 0,
                      child: ListTile(
                        leading: Icon(
                          item.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active_outlined,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.message),
                        isThreeLine: true,
                        onTap: state.busy || item.isRead
                            ? null
                            : () => cubit.read(item.id),
                        trailing: IconButton(
                          tooltip: 'Hapus notifikasi',
                          onPressed: state.busy
                              ? null
                              : () async {
                                  final yes = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus notifikasi?'),
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
                                    cubit.delete(item.id);
                                  }
                                },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
}
